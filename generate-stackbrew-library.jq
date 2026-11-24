# emits the given version followed by each of its less specific parents, stopping at $stop ("29.10.0" with a $stop of "29" emits "29.10.0", "29.10", "29")
def version_chain($stop):
	.,
	(
		select(. != $stop and test("[.-]"))
		| sub("[.-][^.-]*$"; "")
		| version_chain($stop)
	)
;

# whether the given architecture of the given version has everything the given variant needs
def arch_supported($version; $arch; $name):
	$version.arches[$arch] as $files
	| $files.cliUrl
	and (
		if $name | startswith("dind") then
			$files.engineUrl
			# "dockerd" embeds containerd, but we still need the shim and "ctr" (and "runc"), which come from their own releases
			and $version.containerd.arches[$arch]
			and $version.runc.arches[$arch]
			and ($name != "dind-rootless" or $files.rootlessExtrasUrl)
		else true end
	)
;

map_values(select(.)) # ignore nulls ("29-rc" post-GA)
| to_entries
# sort version numbers with highest first
| sort_by(.key | split("[.-]"; "") | map(try tonumber // .))
| reverse
| . as $entries

# our entries are in precedence order, so loop over them in order and assign "generic" aliases like "29" and "latest" to the first entry that might use them
| (
	reduce .[] as $e ({ taken: {}, aliases: {} };
		$e.key as $key
		| ($key | rtrimstr("-rc")) as $rcVersion
		| $e.value.version as $fullVersion
		| (
			if $key == $rcVersion then
				[ $fullVersion | version_chain($key) ] as $chain
				| $chain[:-1] + [ $key | select(. != $chain[-1]) ] # "29.10.0", "29.10"
			else
				[ $fullVersion, ($key | select(. != $fullVersion)) ] # "29.10.0-rc.2", "29-rc"
			end
		) as $aliases
		| .taken as $taken
		| [
			if $key == $rcVersion then
				($key | split(".")[0]), # "29"
				"latest"
			else "rc" end
			| select($taken[.] | not)
		] as $extra
		| .taken += ($extra | map({ (.): $key }) | add // {})
		| .aliases[$key] = $aliases + $extra
	)
	| .aliases
) as $versionAliases

| $entries[]
| .key as $key
| .value as $version

# only the versions asked for "./generate-stackbrew-library.sh X Y ..."
| select($ARGS.positional == [] or IN($key; $ARGS.positional[]))

| $versionAliases[$key] as $aliases
| ($parents[$key] | sub("^[^:]*:"; "")) as $alpine # "3.24"

| $version.variants[] as $variant # "cli", "windows/windowsservercore-ltsc2025", etc
| ($variant | split("/")[-1]) as $name # "cli", "windowsservercore-ltsc2025", etc

# skip variants that do not have a Dockerfile
| $commits["\($key)/\($variant)"] as $commit
| select($commit)

# Tags:
| (
	$aliases
	| map(if . == "latest" then $name else "\(.)-\($name)" end)
) as $variantAliases
| [
	$variantAliases[],
	if $name | IN("cli", "dind") then
		"\($variantAliases[0])-alpine\($alpine)",
		if $name == "dind" then
			# dind is our "default" variant, so it gets the plain version tags too
			$aliases[],
			"\($aliases[0])-alpine\($alpine)",
			empty
		else empty end,
		empty
	else empty end,
	empty
] as $tags

# SharedTags:
| [
	if $name | startswith("windowsservercore") then
		$aliases[]
		| if . == "latest" then
			"windowsservercore"
		else "\(.)-windowsservercore" end
	else empty end
] as $sharedTags

# Architectures:
| (
	$version.arches
	| keys
	| map(select(arch_supported($version; .; $name)))
	| if $variant | startswith("windows/") then
		map(select(startswith("windows-")))
	else
		. - (
			. - (
				$parentsArches[$parents[$key]]
				// error("no architectures found for parent image: \($parents[$key])")
			)
		) # intersection
	end
) as $arches

| (
	"",
	"Tags: \($tags | join(", "))",
	if $sharedTags != [] then
		"SharedTags: \($sharedTags | join(", "))"
	else empty end,
	"Architectures: \($arches | join(", "))",
	"GitCommit: \($commit)",
	"Directory: \($key)/\($variant)",
	if $variant != $name then
		"Constraints: \($name)",
		"Builder: classic", # no Windows support in BuildKit (yet)
		empty
	else empty end,
	empty
)

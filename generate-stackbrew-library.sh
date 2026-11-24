#!/usr/bin/env bash
set -Eeuo pipefail

self="$(basename "$BASH_SOURCE")"
cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

# get the most recent commit which modified any of "$@"
fileCommit() {
	git log -1 --format='format:%H' HEAD -- "$@"
}

# get the most recent commit which modified "$1/Dockerfile" or any file COPY'd from "$1/Dockerfile"
dirCommit() {
	local dir="$1"; shift
	(
		cd "$dir"
		fileCommit \
			Dockerfile \
			$(git show HEAD:./Dockerfile | awk '
				toupper($1) == "COPY" {
					for (i = 2; i < NF; i++) {
						print $i
					}
				}
			')
	)
}

# "29/cli", "29/windows/windowsservercore-ltsc2025", etc
dirs="$(
	jq --raw-output '
		to_entries[]
		| select(.value)
		| .key as $version
		| .value.variants[]
		| "\($version)/\(.)"
		| @sh
	' versions.json
)"
eval "dirs=( $dirs )"

commits='{}'
parents='{}'
for dir in "${dirs[@]}"; do
	[ -f "$dir/Dockerfile" ] || continue

	commit="$(dirCommit "$dir")"
	commits="$(jq <<<"$commits" --compact-output --arg dir "$dir" --arg commit "$commit" '.[$dir] = $commit')"

	# only "cli" is FROM our base image (the other variants are FROM it), so that is where we find out which parent image's architectures limit us
	version="${dir%%/*}"
	if [ "${dir#*/}" = 'cli' ]; then
		parent="$(jq --raw-input --null-input --raw-output 'first(inputs | capture("^FROM (?<parent>[^ ]+)"; "i").parent)' "$dir/Dockerfile")"
		[ -n "$parent" ]
		parents="$(jq <<<"$parents" --compact-output --arg version "$version" --arg parent "$parent" '.[$version] = $parent')"
	fi
done

getArches() {
	local oiBase="${BASHBREW_LIBRARY:-https://github.com/docker-library/official-images/raw/HEAD/library}/"

	# grab supported architectures for each parent image
	jq <<<"$parents" --raw-output --arg oiBase "$oiBase" '[ .[] ] | unique[] | $oiBase + .' \
		| xargs -r bashbrew cat --format '{ {{ join ":" .RepoName .TagName | json }}: {{ json .TagEntry.Architectures }} }' \
		| jq --compact-output --slurp 'add // {}'
}
parentsArches="$(getArches)"

cat <<-EOH
# this file is generated via https://github.com/docker-library/docker/blob/$(fileCommit "$self")/$self

Maintainers: Tianon Gravi <tianon@dockerproject.org> (@tianon),
             Joseph Ferguson <yosifkit@gmail.com> (@yosifkit)
GitRepo: https://github.com/docker-library/docker.git
Builder: buildkit
EOH

exec jq \
	--raw-output \
	--argjson commits "$commits" \
	--argjson parents "$parents" \
	--argjson parentsArches "$parentsArches" \
	--from-file generate-stackbrew-library.jq \
	versions.json \
	--args -- "$@"

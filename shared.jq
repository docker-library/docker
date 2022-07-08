# converts a bashbrew architecture to apk's strings
def apkArch:
	{
		# https://dl-cdn.alpinelinux.org/alpine/edge/main/
		# https://wiki.alpinelinux.org/wiki/Architecture#Alpine_Hardware_Architecture_.28.22arch.22.29_Support
		# https://pkgs.alpinelinux.org/packages ("Arch" dropdown)
		amd64: "x86_64",
		arm32v6: "armhf",
		arm32v7: "armv7",
		arm64v8: "aarch64",
		i386: "x86",
		ppc64le: "ppc64le",
		riscv64: "riscv64",
		s390x: "s390x",
	}[.]
	;

# RUN set -eux; \
# 	...
# 	{{
# 		download({
# 			arches: .arches,
# 			urlKey: "dockerUrl",
# 			#sha256Key: "sha256",
# 			target: "docker.tgz",
# 			#missingArchWarning: true,
# 		})
# 	}}; \
# 	...
def download(opts):
	(opts.sha256Key | not) as $notSha256
	| [
	"apkArch=\"$(apk --print-arch)\";
	case \"$apkArch\" in"
		,
		(
		opts.arches | to_entries[]
		| .key as $bashbrewArch
		| ($bashbrewArch | apkArch) as $apkArch
		| .value
		| .[opts.urlKey] as $url
		| (if $notSha256 then "none" else .[opts.sha256Key] end) as $sha256
		| select($apkArch and $url and $sha256)
		| ("
		\($apkArch | @sh))
			url=\($url | @sh);"
			+ if $notSha256 then "" else "
			sha256=\($sha256 | @sh);"
			end + "
			;;"
			)
		)
		,
		"
		*) echo >&2 \"\(if opts.missingArchWarning then "warning" else "error" end): unsupported \(opts.target | @sh) architecture ($apkArch)\(if opts.missingArchWarning then "; skipping" else "" end)\"; exit \(if opts.missingArchWarning then 0 else 1 end) ;;
	esac;
	
	wget -O \(opts.target | @sh) \"$url\";"
	,
	if $notSha256 then "" else "
	echo \"$sha256 *\"\(opts.target | @sh) | sha256sum -c -;"
	end
	] | add
	| rtrimstr(";")
	| gsub("(?<=[^[:space:]])\n"; " \\\n")
	| gsub("(?<=[[:space:]])\n"; "\\\n")
	;

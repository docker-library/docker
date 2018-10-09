#!/bin/bash
set -eo pipefail

defaultAlpineVersion='3.8'
declare -A alpineVersion=(
	#[17.09]='3.6'
)

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

source '.architectures-lib'

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */ )
fi
versions=( "${versions[@]%/}" )

# see http://stackoverflow.com/a/2705678/433558
sed_escape_lhs() {
	echo "$@" | sed -e 's/[]\/$*.^|[]/\\&/g'
}
sed_escape_rhs() {
	echo "$@" | sed -e 's/[\/&]/\\&/g' | sed -e ':a;N;$!ba;s/\n/\\n/g'
}

# "tac|tac" for http://stackoverflow.com/a/28879552/433558
dindLatest="$(curl -fsSL 'https://github.com/docker/docker/commits/master/hack/dind.atom' | tac|tac | awk -F '[[:space:]]*[<>/]+' '$2 == "id" && $3 ~ /Commit/ { print $4; exit }')"

dockerVersions="$(
	git ls-remote --tags https://github.com/docker/docker-ce.git \
		| cut -d$'\t' -f2 \
		| grep '^refs/tags/v[0-9].*$' \
		| sed 's!^refs/tags/v!!; s!\^{}$!!' \
		| sort -u \
		| gawk '
			{ data[lines++] = $0 }

			# "beta" sorts lower than "tp" even though "beta" is a more preferred release, so we need to explicitly adjust the sorting order for RCs
			# also, "18.09.0-ce-beta1" vs "18.09.0-beta3"
			function docker_version_compare(i1, v1, i2, v2, l, r) {
				l = v1; gsub(/-ce/, "", l); gsub(/-tp/, "-alpha", l)
				r = v2; gsub(/-ce/, "", r); gsub(/-tp/, "-alpha", r)
				patsplit(l, ltemp, /[^.-]+/)
				patsplit(r, rtemp, /[^.-]+/)
				for (i = 0; i < length(ltemp) && i < length(rtemp); ++i) {
					if (ltemp[i] < rtemp[i]) {
						return -1
					}
					if (ltemp[i] > rtemp[i]) {
						return 1
					}
				}
				return 0
			}

			END {
				asort(data, result, "docker_version_compare")
				for (i in result) {
					print result[i]
				}
			}
		'
)"

travisEnv=
appveyorEnv=
for version in "${versions[@]}"; do
	rcVersion="${version%-rc}"

	versionOptions="$(grep "^$rcVersion[.]" <<<"$dockerVersions")"

	rcGrepV='-v'
	if [ "$rcVersion" != "$version" ]; then
		rcGrepV=
	fi

	fullVersion="$(grep $rcGrepV -E -- '-(rc|tp|beta)' <<<"$versionOptions" | tail -1)"
	if [ -z "$fullVersion" ]; then
		echo >&2 "warning: cannot find full version for $version"
		continue
	fi

	channel="$(versionChannel "$version")"

	echo "$version: $fullVersion ($channel)"

	archCase='apkArch="$(apk --print-arch)"; '$'\\\n'
	archCase+=$'\t''case "$apkArch" in '$'\\\n'
	for apkArch in $(apkArches "$version"); do
		dockerArch="$(apkToDockerArch "$version" "$apkArch")"
		archCase+=$'\t\t'"$apkArch) dockerArch='$dockerArch' ;; "$'\\\n'
	done
	archCase+=$'\t\t''*) echo >&2 "error: unsupported architecture ($apkArch)"; exit 1 ;;'$'\\\n'
	archCase+=$'\t''esac'

	alpine="${alpineVersion[$version]:-$defaultAlpineVersion}"

	majorVersion="${fullVersion%%.*}"
	minorVersion="${fullVersion#$majorVersion.}"
	minorVersion="${minorVersion%%.*}"
	minorVersion="${minorVersion#0}"

	for variant in \
		'' git dind \
		windows/windowsservercore-{1709,ltsc2016} \
	; do
		dir="$version${variant:+/$variant}"
		[ -d "$dir" ] || continue
		df="$dir/Dockerfile"
		slash='/'
		case "$variant" in
			windows/windowsservercore*) tag="${variant#*-}"; template='Dockerfile-windows-windowsservercore.template' ;;
			*) tag="$alpine"; template="Dockerfile${variant:+-${variant//$slash/-}}.template" ;;
		esac
		sed -r \
			-e 's!%%VERSION%%!'"$version"'!g' \
			-e 's!%%DOCKER-CHANNEL%%!'"$channel"'!g' \
			-e 's!%%DOCKER-VERSION%%!'"$fullVersion"'!g' \
			-e 's!%%TAG%%!'"$tag"'!g' \
			-e 's!%%DIND-COMMIT%%!'"$dindLatest"'!g' \
			-e 's!%%ARCH-CASE%%!'"$(sed_escape_rhs "$archCase")"'!g' \
			"$template" > "$df"

		# pigz (https://github.com/moby/moby/pull/35697) is only 18.02+
		if [ "$majorVersion" -lt 18 ] || { [ "$majorVersion" -eq 18 ] && [ "$minorVersion" -lt 2 ]; }; then
			sed -ri '/pigz/d' "$df"
		fi

		if [[ "$variant" == windows/* ]]; then
			winVariant="$(basename "$variant")"

			case "$winVariant" in
				*-1709) ;; # no AppVeyor support for 1709 yet: https://github.com/appveyor/ci/issues/1885
				*) appveyorEnv='\n    - version: '"$version"'\n      variant: '"$winVariant$appveyorEnv" ;;
			esac
		fi
	done

	cp -a docker-entrypoint.sh modprobe.sh "$version/"
	cp -a dockerd-entrypoint.sh "$version/dind/"

	travisEnv='\n  - VERSION='"$version$travisEnv"
done

travis="$(awk -v 'RS=\n\n' '$1 == "env:" { $0 = "env:'"$travisEnv"'" } { printf "%s%s", $0, RS }' .travis.yml)"
echo "$travis" > .travis.yml

if [ -f .appveyor.yml ]; then
	appveyor="$(awk -v 'RS=\n\n' '$1 == "environment:" { $0 = "environment:\n  matrix:'"$appveyorEnv"'" } { printf "%s%s", $0, RS }' .appveyor.yml)"
	echo "$appveyor" > .appveyor.yml
fi

#!/bin/sh
set -e

INSTRUCTIONS=""
# debian requires setting unprivileged_userns_clone
if [ -f /proc/sys/kernel/unprivileged_userns_clone ]; then
	if [ "1" != "$(cat /proc/sys/kernel/unprivileged_userns_clone)" ]; then
		INSTRUCTIONS="${INSTRUCTIONS}
cat <<EOT > /etc/sysctl.d/50-rootless.conf
kernel.unprivileged_userns_clone = 1
EOT
sysctl --system"
	fi
fi

# centos requires setting max_user_namespaces
if [ -f /proc/sys/user/max_user_namespaces ]; then
	if [ "0" = "$(cat /proc/sys/user/max_user_namespaces)" ]; then
		INSTRUCTIONS="${INSTRUCTIONS}
cat <<EOT > /etc/sysctl.d/51-rootless.conf
user.max_user_namespaces = 28633
EOT
sysctl --system"
	fi
fi

if [ -n "$INSTRUCTIONS" ]; then
	echo "# Missing system requirements. Please run following commands on the host."
	echo
	echo "$INSTRUCTIONS"
	exit 1
fi

DOCKERD_FLAGS="--experimental"
# detect if overlay is supported (ubuntu)
tmpdir=$(mktemp -d)
mkdir -p $tmpdir/lower $tmpdir/upper $tmpdir/work $tmpdir/merged
if rootlesskit mount -t overlay overlay -olowerdir=$tmpdir/lower,upperdir=$tmpdir/upper,workdir=$tmpdir/work $tmpdir/merged >/dev/null 2>&1; then
	DOCKERD_FLAGS="$DOCKERD_FLAGS --storage-driver=overlay2"
else
	DOCKERD_FLAGS="$DOCKERD_FLAGS --storage-driver=vfs"
fi
rm -rf "$tmpdir"

exec dockerd-rootless.sh "$DOCKERD_FLAGS" "$@"

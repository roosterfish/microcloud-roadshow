agent_waitready() {
	local instance project
	instance="${1}"
	project="${2}"

	for _ in $(seq 90); do
		if lxc exec "${instance}" --project "${project}" -- echo "==> VM agent is ready" 2>/dev/null; then
			return 0
		fi

		sleep 1
	done

	return 1
}

snap_waitready() {
	local instance project
	instance="${1}"
	project="${2}"

	lxc exec "${instance}" --project "${project}" -- snap wait system seed.loaded && echo "==> snapd is ready"
}

cleanup() {
	if [[ "$?" != "0" ]]; then
		lxc rm -f m1 m2 m3 || true
		lxc network rm microcloud || true
		seq 1 3 | xargs -P 3 -I {} lxc storage volume rm default volm{}
	fi
}

export -f agent_waitready
export -f snap_waitready

trap cleanup EXIT
set -e
set -o pipefail

seq 1 3 | xargs -P 3 -I {} lxc launch ubuntu:jammy m{} --vm -c limits.cpu=4 -c limits.memory=4GB
seq 1 3 | xargs -P 3 -I {} lxc storage volume create default volm{} size=4GB --type block
seq 1 3 | xargs -P 3 -I {} lxc storage volume attach default volm{} m{}

lxc network create microcloud ipv6.address=none
seq 1 3 | xargs -P 3 -I {} lxc network attach microcloud m{}

seq 1 3 | xargs -P 3 -I {} bash -c "agent_waitready m{} default"
seq 1 3 | xargs -P 3 -I {} bash -c "snap_waitready m{} default"

seq 1 3 | xargs -P 3 -I {} lxc exec m{} -- ip link set enp6s0 up
seq 1 3 | xargs -P 3 -I {} lxc exec m{} -- snap remove lxd --purge

seq 1 3 | xargs -P 3 -I {} lxc exec m{} -- snap install lxd microceph microovn microcloud

uplink_base="$(lxc query /1.0/networks/microcloud | jq -r '.config."ipv4.address"' | awk -F"/" '{print $1}')"

preseed="$(cat <<EOF
lookup_subnet: $(lxc query /1.0/instances/m1?recursion=1 | jq -r '.state.network.enp5s0.addresses[0].address')/$(lxc query /1.0/instances/m1?recursion=1 | jq -r '.state.network.enp5s0.addresses[0].netmask')
systems:
- name: m1
  ovn_uplink_interface: enp6s0
  storage:
    ceph:
      - path: /dev/sdb
        wipe: true
- name: m2
  ovn_uplink_interface: enp6s0
  storage:
    ceph:
      - path: /dev/sdb
        wipe: true
- name: m3
  ovn_uplink_interface: enp6s0
  storage:
    ceph:
      - path: /dev/sdb
        wipe: true
ovn:
  ipv4_gateway: $(lxc query /1.0/networks/microcloud | jq -r '.config."ipv4.address"')
  ipv4_range: ${uplink_base}00-${uplink_base}50

EOF
)"

echo "$preseed" | lxc exec m1 -- microcloud init --preseed

if [[ "$1" == "cleanup" ]]; then
	cleanup
fi

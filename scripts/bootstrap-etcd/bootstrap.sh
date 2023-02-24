# wget -q --show-progress --https-only --timestamping \
#   "https://github.com/coreos/etcd/releases/download/v3.5.3/etcd-v3.5.3-linux-amd64.tar.gz"
{
for instance in master-1 master-2; do
    vagrant scp etcd-v3.5.3-linux-amd64.tar.gz ${instance}:~/
    vagrant scp setup-etcd.sh ${instance}:~/
done

for instance in master-1 master-2; do
    vagrant ssh ${instance} -- -t 'bash setup-etcd.sh'
done
}
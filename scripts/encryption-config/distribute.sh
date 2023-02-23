{
for instance in master-1 master-2; do
    vagrant scp encryption-config.yaml ${instance}:~/
done

for instance in master-1 master-2; do
    vagrant ssh ${instance} -- -t 'sudo mkdir -p /var/lib/kubernetes/'
    vagrant ssh ${instance} -- -t 'sudo mv encryption-config.yaml /var/lib/kubernetes/'
done
}
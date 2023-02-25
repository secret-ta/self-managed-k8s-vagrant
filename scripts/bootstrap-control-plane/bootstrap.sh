{
for instance in master-1 master-2; do
    vagrant scp setup ${instance}:~/
done

for instance in master-1 master-2; do
    vagrant ssh ${instance} -- -t 'mv setup/* .; rm -rf setup;'
    vagrant ssh ${instance} -- -t 'bash setup-control-plane.sh'
done
}
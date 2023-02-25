vagrant scp setup-tls-bootstrap.sh master-1:~/
vagrant ssh master-1 -- -t 'bash setup-tls-bootstrap.sh'

{
for instance in worker-1 worker-2; do
    vagrant scp setup ${instance}:~/
done

for instance in worker-1 worker-2; do
    vagrant ssh ${instance} -- -t 'mv setup/* .; rm -rf setup;'
    vagrant ssh ${instance} -- -t 'bash setup-cni.sh; bash setup-node.sh;'
done
}

vagrant scp approve-csr.sh master-1:~/
vagrant ssh master-1 -- -t 'bash approve-csr.sh'


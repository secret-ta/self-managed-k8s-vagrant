vagrant scp setup-nlb.sh loadbalancer:~/
vagrant ssh loadbalancer -- -t 'bash setup-nlb.sh'

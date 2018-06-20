# kubernetes templates

Just playing with kubecfg and ksonnet-lib atm.

# Notes

```
docker-compose run kubecfg show -o yaml -v /app/privatebin/privatebin.jsonnet 
docker-compose run kubecfg validate -v /app/privatebin/privatebin.jsonnet 
docker-compose run kubecfg update -v /app/privatebin/privatebin.jsonnet 
docker-compose run kubecfg delete -v /app/privatebin/privatebin.jsonnet
```


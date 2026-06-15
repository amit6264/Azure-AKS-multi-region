output "clusters" {

  value = {

    for k,v in module.aks :

    k => v.cluster_name

  }

}

# HashiStack


## Nomad and Consul Separate Clusters Example
This folder shows an example of Terraform code to deploy a Nomad cluster that connects to a separate Consul cluster in AWS (if you want to run Nomad and Consul in the same clusters, see the nomad-consul-colocated-cluster example instead). The Nomad cluster consists of two Auto Scaling Groups (ASGs): one with a small number of Nomad server nodes, which are responsible for being part of the consensus quorum, and one with a larger number of Nomad client nodes, which are used to run jobs:

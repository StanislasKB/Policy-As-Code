package pipeline.policy
import future.keywords


# Politique : Version Terraform
# Objectif : S'assurer que la version de Terraform utilisée est conforme à une version spécifique.
default allow_terraform_version = false
allow_terraform_version {
   input.format_version == "1.2" 
   input.terraform_version == "1.7.3"
}

# Politique de Version d'AMI
# Objectif : S'assurer que seules les versions d'AMI approuvées sont utilisées.
default allow_ami = false
allow_ami {
     every instance in input.planned_values.root_module.resources
    {
      instance.values.ami == "ami-0c7217cdde317cfec"
    }
   
   
}

# Politique de Clé SSH
# Objectif : Garantir l'utilisation de clés SSH approuvées.
default allow_ssh_key = false
 allow_ssh_key {
    every instance in input.planned_values.root_module.resources
     {instance.values.key_name  == "vprofile-sonar-key"}
 }

# Politique de Taille d'Instance
# Objectif : Limiter l'utilisation de certaines tailles d'instance.
default allow_instance_type = false

allow_instance_type {
    every instance in input.planned_values.root_module.resources
    {instance.values.instance_type == "t2.micro"}
 }

# Politique de Groupe de Sécurité
# Objectif : S'assurer que les instances utilisent uniquement le groupe de sécurité Jenkins.
default allow_security_group = false

allow_security_group {
    every instance in input.planned_values.root_module.resources {
       instance.values.vpc_security_group_ids[_] == "sg-0b85f82d974c1e318"
    }
 }

# Politique de Tags
# Objectif : Garantir la présence d'un tag "Name", "Team" et "Product" pour chaque instance.
default allow_tags = false
 allow_tags {
   every input_instance in input.planned_values.root_module.resources  {
       input_instance.values.tags.Name
       input_instance.values.tags.Team
       input_instance.values.tags.Product
    }
 }

#Politique de Gestion des données utilisateur
#Objectif : S'assurer que les données utilisateur de l'instance EC2 ne contiennent pas de secrets
default allow_without_secrets = false
allow_without_secrets {
    not (ec2_user_data_no_secrets)
}

ec2_user_data_no_secrets {
  check_sample_access_secret_key
}

check_sample_access_secret_key{
   every instance in input.planned_values.root_module.resources
  {count(regex.find_n(".*(A3T[A-Z0-9]|AKIA|AGPA|AIDA|AROA|AIPA|ANPA|ANVA|ASIA)[A-Z0-9]{16}.*", instance.user_data, -1)) >0}
}

check_sample_access_secret_key{
every instance in input.planned_values.root_module.resources
  {count(regex.find_n("([A-Za-z0-9\\\\\\\/+\\\\]{40})", instance.user_data,-1))>0}
}

# Politique : Validation des instantanés de volumes EBS
# Objectif : Assurer que les instantanés de volumes EBS sont correctement configurés et chiffrés
default validate_ebs_snapshots = false
validate_ebs_snapshots {
   every snapshot in input.planned_values.root_module.resources {
      snapshot.values.ebs_block_device[_].volume_type == "gp2" 
      snapshot.values.ebs_block_device[_].encrypted
   }
}



aws_account_id  = "303541348648"
aws_main_region = "us-west-2"
aws_dr_region   = "us-east-2"
enable_dr       = false

k8_cluster_name    = "demo.k8s.local"
k8s_state_s3bucket = "fispan-infra-kubernetes-nonprod"
k8s_ssh_key_pub    = "keys/fispan-kube-demo.pub"
TF-state-lock      = "demo_tfstate_lock"

environment_shared_tags = {
  environment = "demo"
}

cross_account_roles = [
  {
    name_prefix = "teamcity_agent_access"
    description = "Grant teamcity agent access to resources below"
    iam_role_actions = [
      {
        actions = [
          "route53:ListHostedZonesByName"
        ]
        resource = ["*"]
      },
      {
        actions = [
          "route53:ChangeResourceRecordSets",
          "route53:ListResourceRecordSets",
        ]
        resource = [
          "arn:aws:route53:::hostedzone/Z0448930PP89VD4NNK8S",
        ]
      }
    ]
    principal_type = "AWS"
    principal = [
      "arn:aws:iam::500404063477:role/teamcity_agent_role",
      "arn:aws:iam::500404063477:user/ci-user"
    ]
  }
]

sgs_group_rules = [
  {
    name        = "zscaler-ssh-access"
    type        = "ingress"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["172.21.24.0/21"]
  },
  {
    name        = "egress"
    type        = "egress"
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }
]

general_s3_buckets = [
  {
    bucket_name             = "demo-https-certs"
    enable_dr               = false
    custom_policies         = []
    custom_policies_dr      = []
    bucket_key_enabled      = true
    custom_transition_rules = []
    custom_expiration_rule = [
      {
        id   = "delete"
        days = 365
      }
    ]
    tags = {}
  }
]

static_resource_buckets = {
  "static-resources.demos.fispan.cloud" = {
    dns_zone_id            = "Z0448930PP89VD4NNK8S"
    bucket_name            = "static-resources.demos.fispan.cloud"
    bucket_dns_name        = "static.demos.fispan.cloud"
    default_cached_methods = ["GET", "HEAD"]
    acm_cert_arn           = "arn:aws:acm:us-east-1:303541348648:certificate/4281fc0b-0c91-4653-a897-132aea0fee7d"
    custom_policies = [
      {
        sid = "CloudFrontAccess"
        actions = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        resource = [
          "arn:aws:s3:::static-resources.demos.fispan.cloud/*",
          "arn:aws:s3:::static-resources.demos.fispan.cloud"
        ]
        principal_type = "AWS"
        principals     = ["arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity E1SS3L7NMJUCBE"]
      },
      {
        sid            = "CIUserBucketAccess"
        actions        = ["s3:ListBucket"]
        resource       = ["arn:aws:s3:::static-resources.demos.fispan.cloud"]
        principal_type = "AWS"
        principals     = ["arn:aws:iam::500404063477:user/ci-user"]
      },
      {
        sid = "CIUserFileAccess"
        actions = [
          "s3:GetObject*",
          "s3:PutObject*",
          "s3:DeleteObject*"
        ]
        resource       = ["arn:aws:s3:::static-resources.demos.fispan.cloud/*"]
        principal_type = "AWS"
        principals     = ["arn:aws:iam::500404063477:user/ci-user"]
      }
    ]
    custom_policies_dr = []
  }
}

kms_encryption_key = {
  key_name    = "demo-encryption-key"
  description = "encryption key for demo"
  enable_dr   = false
  dr_region   = ""
  custom_policies = [
    {
      sid = "Allow AWS autoscaler to use demo encryption KMS key"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]
      principal_type = "AWS"
      principals = [
        "arn:aws:iam::303541348648:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
      ]
      resources = ["*"]
    }
  ]

  custom_policies_conditions = [
    {
      sid            = "Allow AWS autoscaler to create grant for demo encryption KMS key"
      actions        = ["kms:CreateGrant"]
      principal_type = "AWS"
      principals     = ["arn:aws:iam::303541348648:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"]
      resource       = ["*"]
      condition = {
        "test"     = "Bool"
        "variable" = "kms:GrantIsForAWSResource"
        "values"   = ["true"]
      }
    }
  ]
}

atlas_project_name = "demo"

atlas_whitelist_cidrs = [
  "172.18.84.0/24",
  "172.18.85.0/24",
  "172.18.86.0/24"
]

atlas_network_container = [
  {
    atlas_region     = "US_WEST_2"
    atlas_cidr_block = "10.8.0.0/21"
  }
]

atlas_clusters = [
  {
    cluster_name                = "demo-cluster"
    mongo_version               = "6.0"
    atlas_regions               = ["US_WEST_2"]
    provider_disk_iops          = 3000
    use_encryption_at_rest      = "true"
    disk_size                   = 10
    provider_instance_size_name = "M10"
    atlas_replication_factor    = 3
  }
]

atlas_db_users = [
  {
    env_name             = "demo",
    mongo_username       = "demo"
    mongo_password       = "ixQi7t2VpZ7lHQA2Ay"
    mongo_dbname         = "demo_db"
    readWriteAnyDatabase = true
  }
]

enable_s3_endpoints = false
vpc = {
  # name must match active_env_name
  name = "demo"
  cidr = "172.18.80.0/20"

  single_nat_gateway = false

  peering_connections = [
    {
      peer_name     = "teamcity-non-prod-peering"
      peer_owner_id = "500404063477"
      peer_vpc      = "vpc-3439d05d"
      peer_region   = "us-east-2"
    },
    {
      peer_name     = "business-integrations-peering"
      peer_owner_id = "962241040449"
      peer_vpc      = "vpc-0444c76bc223eb832"
      peer_region   = "us-west-2"
    },
  ]

  public_subnets = [
    {
      az          = "us-west-2a"
      cidr        = "172.18.81.0/24"
      firewall_az = "us-west-2a"
      tags_subnet = {
        "Name"                                 = "utility-us-west-2a.demo.k8s.local"
        "kubernetes.io/cluster/demo.k8s.local" = "shared",
        "kubernetes.io/role/elb"               = 1,
        "KubernetesCluster"                    = "demo.k8s.local"
        "SubnetType"                           = "Utility"
      }
    },
    {
      az          = "us-west-2b"
      cidr        = "172.18.82.0/24"
      firewall_az = "us-west-2b"
      tags_subnet = {
        "Name"                                 = "utility-us-west-2b.demo.k8s.local"
        "kubernetes.io/cluster/demo.k8s.local" = "shared",
        "kubernetes.io/role/elb"               = 1,
        "KubernetesCluster"                    = "demo.k8s.local"
        "SubnetType"                           = "Utility"
      }
    },
    {
      az          = "us-west-2c"
      cidr        = "172.18.83.0/24"
      firewall_az = "us-west-2c"
      tags_subnet = {
        "Name"                                 = "utility-us-west-2c.demo.k8s.local"
        "kubernetes.io/cluster/demo.k8s.local" = "shared",
        "kubernetes.io/role/elb"               = 1,
        "KubernetesCluster"                    = "demo.k8s.local"
        "SubnetType"                           = "Utility"
      }
    }
  ]

  firewall_subnets = [
    {
      az   = "us-west-2a"
      cidr = "172.18.90.0/28"
      tags_subnet = {
        "Name"                                 = "firewall-us-west-2a.demo.k8s.local"
        "kubernetes.io/cluster/demo.k8s.local" = "shared",
        "KubernetesCluster"                    = "demo.k8s.local"
        "SubnetType"                           = "Firewall"
      }
    },
    {
      az   = "us-west-2b"
      cidr = "172.18.90.16/28"
      tags_subnet = {
        "Name"                                 = "firewall-us-west-2b.demo.k8s.local"
        "kubernetes.io/cluster/demo.k8s.local" = "shared",
        "KubernetesCluster"                    = "demo.k8s.local"
        "SubnetType"                           = "Firewall"
      }
    },
    {
      az   = "us-west-2c"
      cidr = "172.18.90.32/28"
      tags_subnet = {
        "Name"                                 = "firewall-us-west-2c.demo.k8s.local"
        "kubernetes.io/cluster/demo.k8s.local" = "shared",
        "KubernetesCluster"                    = "demo.k8s.local"
        "SubnetType"                           = "Firewall"
      }
    }
  ]
  firewall_endpoints = [
    {
      az                = "us-west-2a"
      service_name      = "com.amazonaws.vpce.us-west-2.vpce-svc-034fa329101f93d78"
      vpc_endpoint_type = "GatewayLoadBalancer"
    },
    {
      az                = "us-west-2b"
      service_name      = "com.amazonaws.vpce.us-west-2.vpce-svc-034fa329101f93d78"
      vpc_endpoint_type = "GatewayLoadBalancer"
    },
    {
      az                = "us-west-2c"
      service_name      = "com.amazonaws.vpce.us-west-2.vpce-svc-034fa329101f93d78"
      vpc_endpoint_type = "GatewayLoadBalancer"
    }
  ]
}


private_subnets = [
  {
    name = "workers_subnet"
    subnets = [
      {
        az   = "us-west-2a",
        cidr = "172.18.84.0/24",
        name = "worker-us-west-2a.demo.k8s.local"
      },
      {
        az   = "us-west-2b",
        cidr = "172.18.85.0/24",
        name = "worker-us-west-2b.demo.k8s.local"
      },
      {
        az   = "us-west-2c",
        cidr = "172.18.86.0/24",
        name = "worker-us-west-2c.demo.k8s.local"
      }
    ]
    incoming_peerings = [
      {
        cidr               = "172.21.24.0/21"
        peering_connection = "pcx-0036c3e06c8c43fd4"
      }
    ]
    endpoint_routes = []
  },
  {
    name = "masters_subnet"
    subnets = [
      {
        az   = "us-west-2a",
        cidr = "172.18.87.0/24",
        name = "master-us-west-2a.demo.k8s.local"
      },
      {
        az   = "us-west-2b",
        cidr = "172.18.88.0/24",
        name = "master-us-west-2b.demo.k8s.local"
      },
      {
        az   = "us-west-2c",
        cidr = "172.18.89.0/24",
        name = "master-us-west-2c.demo.k8s.local"
      }
    ]
    incoming_peerings = [
      {
        cidr               = "172.21.24.0/21"
        peering_connection = "pcx-0036c3e06c8c43fd4"
      }
    ]
    endpoint_routes = []
  }
]

private_subnet_shared_tags = {
  "kubernetes.io/cluster/demo.k8s.local" = "shared",
  "KubernetesCluster"                    = "demo.k8s.local",
  "kubernetes.io/role/internal-elb"      = "1",
  "SubnetType"                           = "Private",
  "not-used"                             = "not-used"
}

db_private_subnets = [
  {
    name = "db_private_subnet"
    subnets = [
      {
        az   = "us-west-2a"
        cidr = "172.18.80.160/28"
        name = "db-private-us-west-2a-demo"
      },
      {
        az   = "us-west-2b"
        cidr = "172.18.80.176/28"
        name = "db-private-us-west-2b-demo"
      },
      {
        az   = "us-west-2c"
        cidr = "172.18.80.192/28"
        name = "db-private-us-west-2c-demo"
      }
    ]
    incoming_peerings = [
      {
        cidr               = "172.21.24.0/21"
        peering_connection = "pcx-0036c3e06c8c43fd4"
      }
    ]

    subnet_shared_tags = {
      env        = "demo",
      visibility = "private",
      role       = "db"
    }
  }
]

db_security_groups = [
  {
    sg_name        = "db_sg"
    sg_description = "Security group for Postgres DB"
    sg_rules = [
      {
        name        = "inter-vpc-access"
        description = "Access within the VPC"
        type        = "ingress"
        from_port   = "5432"
        to_port     = "5432"
        protocol    = "-1"
        cidr_blocks = ["172.18.80.0/20"] // cidr of the vpc
      },
      {
        name        = "egress"
        description = "Allow all outbound"
        type        = "egress"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      },
      {
        name        = "vpn-access"
        description = "Access from VPN servers"
        type        = "ingress"
        from_port   = 5432 #
        to_port     = 5432
        protocol    = "TCP"
        cidr_blocks = ["172.21.24.0/21"]
      },
      {
        name        = "TeamCity-access"
        description = "Access from TeamCity servers"
        type        = "ingress"
        from_port   = 5432 #
        to_port     = 5432
        protocol    = "TCP"
        cidr_blocks = ["172.31.0.0/16"]
      },
    ]
    tags = {
      Name = "db_sg.demo"
    }
  }
]

k8s_version = "1.24.11"

postgres_dbs = [
  {
    db_name                         = "demo-db"
    schema_name                     = "shared_db"
    username                        = "postgres"
    postgres_version                = 13.8
    backup_retention_period         = 1
    subnet_group_name               = "aurora-postgres_db_subnet_group"
    storage_encrypted               = true
    instance_type                   = "db.t3.medium"
    performance_insights_enabled    = true
    deletion_protection             = false
    aurora_global_cluster           = false
    aurora_dr_instances             = null
    aurora_dr_scaling_configuration = null
    enabled_cloudwatch_logs_exports = []
    aurora_scaling_configuration = {
      min_capacity = 0.5
      max_capacity = 1
    }
    aurora_primary_instances = {
      one = {
        identifier        = "demo-db-instance-1"
        availability_zone = "us-west-2a"
        instance_class    = "db.t4g.large"
      }
    }
  }
]

aurora_parameter_group = [
  {
    name         = "gin_pending_list_limit"
    value        = 64
    apply_method = "immediate"
  }
]

k8_iam_policies = [
  {
    policy_name = "demo-all-node-shared-k8s-policies"
    policy_actions = [
      {
        actions = [
          "ssm:DescribeAssociation",
          "ssm:DescribeDocument",
          "ssm:GetDeployablePatchSnapshotForInstance",
          "ssm:PutConfigurePackageResult",
          "ssm:ListInstanceAssociations",
          "ssm:GetParameters",
          "ssm:UpdateAssociationStatus",
          "ssm:GetManifest",
          "ssm:PutInventory",
          "ssm:UpdateInstanceInformation",
          "ssm:GetDocument",
          "ssm:ListAssociations",
          "ssm:PutComplianceItems",
          "ssm:UpdateInstanceAssociationStatus",
          "ec2messages:GetMessages",
          "ec2messages:GetEndpoint",
          "ec2messages:AcknowledgeMessage",
          "ec2messages:DeleteMessage",
          "ec2messages:FailMessage",
          "ec2messages:SendReply",
          "ec2:DescribeTags"
        ],
        resource = ["*"]
      },
      {
        actions : [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:DescribeTags",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions"
        ],
        resource : ["*"]
      },
      {
        actions = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        resource = [
          "arn:aws:s3:::fispan-infra-ssm-deployments-nonprod",
          "arn:aws:s3:::fispan-infra-ssm-deployments-nonprod/*"
        ]
      },
      {
        actions = [
          "cloudwatch:PutMetricData",
          "ec2:DescribeVolumes",
          "ec2:DescribeTags",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups",
          "logs:CreateLogStream",
          "logs:CreateLogGroup"
        ],
        resource = ["*"]
      },
      {
        actions = [
          "kms:Encrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
          "kms:Decrypt",
        ],
        resource = [
          "arn:aws:kms:us-west-2:050133072996:key/4d5153a7-d681-4735-b9fd-fa4e5d9d4456" // build bucket account access
        ]
      }
    ]
  },
  {
    policy_name = "demo-worker-primary-k8s-policies"
    policy_actions = [
      {
        actions : ["secretsmanager:ListSecrets"],
        resource : ["*"]
      },
      {
        actions = ["secretsmanager:*"]
        resource : [
          "arn:aws:secretsmanager:us-west-2:303541348648:secret:demo/*",
        ]
      },
      {
        actions : ["s3:ListBucket"],
        resource : [
          "arn:aws:s3:::static-resources.demos.fispan.cloud",
        ]
      },
      {
        actions : [
          "s3:GetObject*",
          "s3:PutObject*",
          "s3:DeleteObject*"
        ],
        resource : [
          "arn:aws:s3:::static-resources.demos.fispan.cloud/*",
        ]
      },
      {
        actions : [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        resource : [
          "arn:aws:s3:::fispan-infra-ssm-deployments-nonprod",
          "arn:aws:s3:::fispan-infra-ssm-deployments-nonprod/*"
        ]
      },
      {
        actions : [
          "s3:DeleteObject",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject"
        ],
        resource : [
          "arn:aws:s3:::demo-https-certs/demos.fispan.cloud/*",
          "arn:aws:s3:::demo-https-certs"
        ]
      },
      {
        actions : ["route53:ChangeResourceRecordSets"],
        resource : [
          "arn:aws:route53:::hostedzone/Z0448930PP89VD4NNK8S"
        ]
      },
      {
        actions : [
          "route53:ListHostedZones",
          "route53:GetChange"
        ],
        resource : ["*"]
      },
      {
        actions = [
          "kms:Encrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
          "kms:Decrypt",
        ],
        resource = [
          "arn:aws:kms:us-west-2:303541348648:key/56e6f06e-f425-4cef-aabf-bdbedb9bc4ae", // demo kms encryption key
          "arn:aws:kms:us-west-2:185566784936:key/c3e99ddf-357e-41c1-aca8-7d07611e3083"  // kubernetes logging S3 bucket in Log Archive account
        ]
      },
      {
        //"Sid": "LoggingBucketAccess",
        actions : [
          "s3:PutObject",
          "s3:List*",
          "s3:PutObjectAcl"
        ],
        resource : [
          "arn:aws:s3:::fispan-kubernetes-logs",
          "arn:aws:s3:::fispan-kubernetes-logs/*"
        ]
      },
      {
        actions : [
          "cloudwatch:PutMetricData",
          "ec2:DescribeVolumes",
          "ec2:DescribeTags",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups",
          "logs:CreateLogStream",
          "logs:CreateLogGroup"
        ],
        resource : ["*"]
      },
      {
        actions : [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        resource : [
          "arn:aws:s3:::plugins.fispan.cloud",
          "arn:aws:s3:::plugins.fispan.cloud/*"
        ]
      },
      {
        // "Sid": "ChequeImagesSqsAccess",
        actions : [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        resource : [
          "arn:aws:sqs:us-west-2:303541348648:cheque-images-processing-queue-demo-blue",
          "arn:aws:sqs:us-west-2:303541348648:cheque-images-processing-queue-demo-green",
          "arn:aws:sqs:us-west-2:303541348648:cheque-images-platform-notification-queue-demo-blue",
          "arn:aws:sqs:us-west-2:303541348648:cheque-images-platform-notification-queue-demo-green"
        ]
      },
      {
        // "Sid": "lambdaIncidentsReportSqsAccess",
        actions : [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        resource : [
          "arn:aws:sqs:us-west-2:303541348648:lambda-incident-report-queue-demo-blue",
          "arn:aws:sqs:us-west-2:303541348648:lambda-incident-report-queue-demo-green"
        ],
      },
      //
      {
        // "Sid": "ChequeImagesS3Access",
        actions : [
          "s3:getObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        resource : [
          "arn:aws:s3:::cheque-images.demos.fispan.cloud/*"
        ],
      },
      {
        // "Sid": "FleAssumeRoleAccess",
        actions : [
          "sts:AssumeRole"
        ],
        resource : [
          "arn:aws:iam::826833322305:role/kms-access-role-demo"
        ],
      }
    ]
  }
]

k8_cluster = {
  env_name      = "demo"
  template_name = "demo-kops-cluster.yaml"

  masters_subnet_name    = "masters_subnet"
  workers_subnet_name    = "workers_subnet"
  masters_policy_name    = "master_policies"
  workers_policy_name    = "worker_policies"
  image_version          = "099720109477/ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20230302"
  availability_zones     = ["us-west-2a", "us-west-2b", "us-west-2c"]
  cert_manager_enabled   = true
  metrics_server_enabled = true

  master_root_volume_size = 35
  master_iam_policies = [
    "demo-all-node-shared-k8s-policies"
  ]
  worker_iam_policies = [
    "demo-all-node-shared-k8s-policies",
    "demo-worker-primary-k8s-policies"
  ]

  master_instance_type = "m5a.large"

  dedicated_named_worker_configs = [
    {
      name              = "workers-blue"
      worker_type_label = "worker-blue"
      instance_type     = "t3a.medium"
      root_volume_size  = 30
      min_workers       = 0
      max_workers       = 25
    },
    {
      name              = "workers-green"
      worker_type_label = "worker-green"
      instance_type     = "t3a.medium"
      root_volume_size  = 30
      min_workers       = 0
      max_workers       = 25
    }
  ]

  tools_worker_configs = [
    {
      name              = "tools"
      worker_type_label = "tools"
      instance_type     = "t3a.medium"
      root_volume_size  = 15
      min_workers       = 1
      max_workers       = 4
    }
  ]

  nginx_worker_configs = []

  rabbitmq_worker_configs = [
    {
      name              = "rabbitmq-demo-blue"
      worker_type_label = "rabbitmq-demo-blue"
      instance_type     = "t3a.medium"
      root_volume_size  = 30
      min_workers       = 0
      max_workers       = 3
    },
    {
      name              = "rabbitmq-demo-green"
      worker_type_label = "rabbitmq-demo-green"
      instance_type     = "t3a.medium"
      root_volume_size  = 30
      min_workers       = 0
      max_workers       = 3
    }

  ]

  aws_cluster_shared_tags = <<TAGS
    department: infrastructure
    environment: demo
    ssm-os-install-cis: ubuntu-l1
    ssm-agent-install-crowdstrike: ubuntu
    ssm-agent-install-nessus: none
    data-classification-atrest: none
TAGS

  aws_master_tags = <<TAGS
    data-classification-intransit: none
TAGS

  aws_dedicated_worker_tags = <<TAGS
    data-classification-intransit: highly restricted
TAGS

  aws_worker_tags = <<TAGS
    data-classification-intransit: highly restricted
TAGS

  aws_tools_tags           = <<TAGS
    data-classification-intransit: none
TAGS
  certificate_mount_config = <<CONFIG
  compressUserData: true
  additionalUserData:
  - name: addcert.sh
    type: text/x-shellscript
    content: |
      #!/bin/sh
      sudo tee /usr/local/share/ca-certificates/fispan-ca.crt <<EOF
      -----BEGIN CERTIFICATE-----
      MIIEFTCCAv2gAwIBAgIUMVf4lkc3VrZeWqEJFag9neg5Up0wDQYJKoZIhvcNAQEL
      BQAwgZkxCzAJBgNVBAYTAkNBMRkwFwYDVQQIDBBCcml0aXNoIENvbHVtYmlhMRIw
      EAYDVQQHDAlWYW5jb3V2ZXIxHTAbBgNVBAoMFEZJU1BBTiBTRVJWSUNFUyBJTkMu
      MRswGQYDVQQDDBJmaXNwYW4taW50ZXJuYWwtY2ExHzAdBgkqhkiG9w0BCQEWEGlu
      ZnJhQGZpc3Bhbi5jb20wHhcNMjIwNzI1MjMyMzI4WhcNMzIwNzIyMjMyMzI4WjCB
      mTELMAkGA1UEBhMCQ0ExGTAXBgNVBAgMEEJyaXRpc2ggQ29sdW1iaWExEjAQBgNV
      BAcMCVZhbmNvdXZlcjEdMBsGA1UECgwURklTUEFOIFNFUlZJQ0VTIElOQy4xGzAZ
      BgNVBAMMEmZpc3Bhbi1pbnRlcm5hbC1jYTEfMB0GCSqGSIb3DQEJARYQaW5mcmFA
      ZmlzcGFuLmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMZyiZ99
      65KMxeBJcP5skBs0jGl3co/Q20zcCvH7mq44qvIB1IRHtvVSyjAInLxXsePE1DXb
      aeuzPvEVHcwNHbJK1eGUDPbJfgZvgxjHgBFltY5oTKS1hukVRKVuBB+Q75kmv2aU
      DlBPs8TUNnnW44QrEwF98sJqTN6dsuvHsJliDPhDE/+5M2aFEiahsEAfC2eznVJn
      WeTErtn2b3bqY8sla9osnJJtG9zyUBFI2JHXTiZI7b78X9+aJOsP9lH06h7TWfhQ
      frdlqNencxbcp0QpfGZXCWOCWiSJn9YGoVQ81WNCsFx3yS4AEh5GIo5ISmFTOLOn
      4GWrr83huhe6AJkCAwEAAaNTMFEwHQYDVR0OBBYEFLJCwWUxchOt1mMgPmt+VGdC
      X8BuMB8GA1UdIwQYMBaAFLJCwWUxchOt1mMgPmt+VGdCX8BuMA8GA1UdEwEB/wQF
      MAMBAf8wDQYJKoZIhvcNAQELBQADggEBAKFihlOAFncivVXS1C8qEwLj686F8Buu
      22qjI2HPqzvGUm1F5fpCTtrXXIXXU0VXIUb8Jk5W/UsypcsL12Q9nTlxULfodFEW
      FQi0RUZQ1C1hXi8rRE7ADbcynFdZ7xa/U9OHqlgCW8/WLUBQhbltXZoh/jH+eDId
      vDMkAiGwwTfgqxhr3PhbD1Xazm343fZJnCxORRViCd7Ay/i4tKA3H8AbxJ0HMr71
      k2Kl/7QUujcGokU3yNqqPOML/H11fb3ns8zrto2XpE7DwP7VPIEuIOyL/NyKI7qv
      1TqZJGHj4ZIbHqqZS+6fdzAcNNhClpo2cz2E3I0H3JhorOsj/FZbwuE=
      -----END CERTIFICATE-----
      EOF
      sudo update-ca-certificates
CONFIG
}


k8s_cluster_autoscaler = {
  image                            = "k8s.gcr.io/autoscaling/cluster-autoscaler:v1.24.0"
  enabled                          = true
  expander                         = "least-waste"
  cpu_request                      = "100m"
  memory_request                   = "600Mi"
  new_pod_scale_up_delay           = "5s"
  scale_down_selay_after_add       = "5m0s"
  balance_similar_node_groups      = true
  scale_down_utilization_threshold = "0.5"
}

k8s_cluster_api_server_configs = {
  admission_control_config_file_path = "/srv/kubernetes/kube-apiserver/admission-control-config.yaml"
  audit_policy_file_path             = "/srv/kubernetes/kube-apiserver/policy-config.yaml"
  oidc_issuer_url                    = "https://fispan.onelogin.com/oidc/2"
  oidc_client_id                     = "4c78a840-496a-0139-f57c-0a32a9c605c3179607"
  oidc_username_claim                = "email"
  oidc_username_prefix               = "\"oidc:\""
  oidc_groups_claim                  = "groups"
  oidc_groups_prefix                 = "\"oidc:\""
}

k8s_file_assets_configs = {
  audit_policy_file_path             = "/srv/kubernetes/kube-apiserver/policy-config.yaml"
  admission_control_config_file_path = "/srv/kubernetes/kube-apiserver/admission-control-config.yaml"
  event_rate_limit_config_file_path  = "/srv/kubernetes/kube-apiserver/event-rate-limit-config.yaml"
}

k8s_kubelet_configs = {
  eviction_soft                 = "\"memory.available<350Mi\""
  eviction_soft_grace_period    = "\"memory.available=3m\""
  eviction_max_pod_grace_period = "60"
  eviction_hard                 = "\"memory.available<200Mi,nodefs.available<10%,nodefs.inodesFree<5%,imagefs.available<10%,imagefs.inodesFree<5%\""
  kube_reserved_cpu             = "250m"
  kube_reserved_memory          = "256Mi"
  system_reserved_cpu           = "100m"
  system_reserved_memory        = "128Mi"
  enforce_node_allocatable      = "\"pods\""
}

linkerd_certificate_names = {
  trust_crt   = "demo/LINKERD/ROOT/TRUST/crt"
  trust_key   = "demo/LINKERD/ROOT/TRUST/key"
  webhook_crt = "demo/LINKERD/ROOT/WEBHOOK/crt"
  webhook_key = "demo/LINKERD/ROOT/WEBHOOK/key"
}

elasticache = [
  {
    instance_name            = "demo"
    num_node_groups          = 3
    replicas_per_node_group  = 1
    is_dr_enabled            = false
    is_cluster_mode_enabled  = true
    is_standalone            = false
    is_cluster_mode_disabled = false
  }
]

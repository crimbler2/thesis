locals {
  general_irsa_role_name = "${var.stage}-thesis-sa"
  general_irsa_rola_arn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.general_irsa_role_name}"
}

data "aws_caller_identity" "current" {}

data "tls_certificate" "eks" {
  url = aws_eks_cluster.thesis.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.thesis.identity[0].oidc[0].issuer
}

data "aws_iam_policy_document" "thesis-sa-assume" {
  // allow crossplane and argocd to assume this role
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:crossplane-system:*", "system:serviceaccount:argocd-system:*"]
    }
  }

  // allow myself to assume role to debug created clusters
  statement {
    actions = ["sts:AssumeRole", "sts:SetSourceIdentity"]
    effect  = "Allow"

    principals {
      identifiers = ["arn:aws:sts::111802884793:assumed-role/sso/Ismail.Huerriyetoglu@bmw.de"]
      type        = "AWS"
    }
  }

  // allow this role to assume itself because ArgoCD will do that, use condition for arn checking to allow cyclic dependency
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = ["*"]
      type        = "AWS"
    }

    condition {
      test     = "ArnLike"
      variable = "aws:PrincipalArn"
      values   = [local.general_irsa_rola_arn]
    }
  }
}

resource "aws_iam_role" "thesis-sa" {
  name               = local.general_irsa_role_name
  // use string directly to break cyclic dependency occurring from role being allowed to assume itself
  assume_role_policy = data.aws_iam_policy_document.thesis-sa-assume.json
}

resource "aws_iam_policy" "thesis-sa-allow-everything" {
  name = "${local.general_irsa_role_name}-allow-everything"

  policy = jsonencode({
    Statement = [
      {
        Action = [
          "*",
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "test_attach" {
  role       = aws_iam_role.thesis-sa.name
  policy_arn = aws_iam_policy.thesis-sa-allow-everything.arn
}

output "test_policy_arn" {
  value = aws_iam_role.thesis-sa.arn
}

data "aws_iam_policy_document" "external-secrets-irsa-assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringLike"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:team2:*"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "external-secrets-irsa" {
  assume_role_policy = data.aws_iam_policy_document.external-secrets-irsa-assume.json
  name               = "${var.stage}-external-secrets-irsa"
}

resource "aws_iam_policy" "external-secrets-irsa" {
  name = "${var.stage}-external-secrets-irsa-secretsmanager-access"

  policy = jsonencode({
    Statement = [
      {
        Action = [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:secretsmanager:eu-central-1:843588259092:secret:*"
      }
    ]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "external-secrets-irsa" {
  role       = aws_iam_role.external-secrets-irsa.name
  policy_arn = aws_iam_policy.external-secrets-irsa.arn
}
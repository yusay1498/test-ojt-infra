# ------------------------------------------------------------
# prod 環境変数
# 実際の値に置き換えてください
# ------------------------------------------------------------

vpc_id         = "" # 例: "vpc-xxxxxxxxxxxxxxxxx"
subnet_id      = "" # 例: "subnet-xxxxxxxxxxxxxxxxx" (プライベートサブネット)
vpc_cidr_block = "" # 例: "10.0.0.0/16"

# RDS 作成後に設定してください
# rds_security_group_id = "sg-xxxxxxxxxxxxxxxxx"

# IAM ロールを既存のものを使う場合は以下を設定し、create_iam_role = false に変更してください
# create_iam_role           = false
# iam_instance_profile_name = "existing-instance-profile-name"

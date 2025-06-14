resource "null_resource" "db_init" {
  depends_on = [aws_db_instance.k3s]

  provisioner "local-exec" {
    command = <<-EOF
      # Wait for RDS to be available
      aws rds wait db-instance-available --db-instance-identifier ${aws_db_instance.k3s.identifier}
      
      # Create initialization SQL script
      cat > /tmp/init_k3s_db.sql << 'SQL'
-- Create databases for each cluster
CREATE DATABASE k3s_cluster1;
CREATE DATABASE k3s_cluster2;

-- Create dedicated user for K3s
CREATE USER k3s_user WITH PASSWORD '${random_password.k3s_user_password.result}';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE k3s_cluster1 TO k3s_user;
GRANT ALL PRIVILEGES ON DATABASE k3s_cluster2 TO k3s_user;

-- Connect to each database and grant schema permissions
\c k3s_cluster1;
GRANT ALL ON SCHEMA public TO k3s_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO k3s_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO k3s_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO k3s_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO k3s_user;

\c k3s_cluster2;
GRANT ALL ON SCHEMA public TO k3s_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO k3s_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO k3s_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO k3s_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO k3s_user;
SQL

      # Execute the SQL script
      PGPASSWORD='${data.aws_ssm_parameter.etcd_master_password.value}' psql \
        -h ${aws_db_instance.k3s.endpoint} \
        -U k3s_admin \
        -d postgres \
        -f /tmp/init_k3s_db.sql
      
      # Clean up
      rm /tmp/init_k3s_db.sql
    EOF
  }
}

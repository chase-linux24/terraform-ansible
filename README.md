# Terraform + Ansible — Automated Web Server Infrastructure

A production-style DevOps project combining Terraform and Ansible to provision and configure AWS infrastructure. Terraform builds the servers, Ansible configures them — demonstrating the real-world separation of concerns used in DevOps pipelines.

---

## What This Project Does

- Provisions **4 EC2 instances** on AWS using Terraform (1 control node + 3 web servers)
- Configures **2 security groups** with least-privilege rules defined in code
- Uses **Ansible** from the control node to install and start NGINX on all 3 web servers simultaneously
- Demonstrates the **Terraform + Ansible workflow** used in real DevOps environments

---

## Architecture

```
Your Machine (Windows)
    │
    └── Terraform provisions AWS infrastructure
            │
            ├── ControlNode EC2 (runs Ansible)
            │       │
            │       └── Ansible SSHes into all 3 web servers
            │               │
            ├── WebServer1 EC2 ──► NGINX installed + running
            ├── WebServer2 EC2 ──► NGINX installed + running
            └── WebServer3 EC2 ──► NGINX installed + running
```

---

## Tech Stack

| Tool | Purpose |
|------|---------|
| Terraform v1.15.3 | Provision EC2 instances and security groups |
| Ansible Core 2.15.3 | Install and configure NGINX on web servers |
| AWS EC2 | Virtual machine compute (t2.micro) |
| AWS Security Groups | Least-privilege firewall rules |
| AWS Key Pair | SSH authentication between instances |
| Amazon Linux 2023 | OS for all 4 instances |

---

## Project Structure

```
terraform-ansible/
├── main.tf                  # All AWS resources — provider, security groups, EC2 instances
├── .terraform.lock.hcl      # Provider version lock file
└── .gitignore               # Excludes .pem key and state files
```

**Files created on the ControlNode (not in repo):**
```
~/inventory.ini              # Ansible inventory — lists web server IPs
~/playbook.yml               # Ansible playbook — installs and starts NGINX
~/.ssh/ansible-key.pem       # Private key for SSH authentication
```

---

## How It Works

### Step 1 — Terraform Provisions Infrastructure
```bash
terraform init
terraform plan
terraform apply
```
Creates 4 EC2 instances and 2 security groups in AWS us-east-1.

### Step 2 — SSH Into Control Node
```bash
ssh -i ansible-key.pem ec2-user@<control_node_ip>
```

### Step 3 — Install Ansible on Control Node
```bash
sudo dnf install ansible-core -y
```

### Step 4 — Create Inventory File
```ini
[webservers]
<web1_ip>
<web2_ip>
<web3_ip>

[webservers:vars]
ansible_user=ec2-user
ansible_ssh_private_key_file=~/.ssh/ansible-key.pem
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

### Step 5 — Test Connectivity
```bash
ansible -i ~/inventory.ini webservers -m ping
```

### Step 6 — Run the Playbook
```bash
ansible-playbook -i ~/inventory.ini ~/playbook.yml
```

### Step 7 — Verify NGINX
```bash
systemctl status nginx
```

---

## Ansible Playbook

```yaml
---
- name: Install and configure NGINX on web servers
  hosts: webservers
  become: yes

  tasks:
    - name: Install NGINX
      dnf:
        name: nginx
        state: present

    - name: Ensure NGINX is running
      service:
        name: nginx
        state: started
        enabled: yes
```

---

## Security Practices

- SSH key pair generated via AWS CLI — private key never hardcoded
- `.pem` file excluded from Git via `.gitignore`
- Web servers: SSH (22) + HTTP (80) only
- Control node: SSH (22) only — no unnecessary ports open
- `chmod 400` applied to private key on control node

---

## Key Concepts Demonstrated

- **IaC + Configuration Management** — Terraform handles infrastructure, Ansible handles configuration
- **Agentless automation** — Ansible uses SSH, no agent installed on web servers
- **Idempotency** — running the playbook again produces the same result
- **Inventory groups** — targeting multiple servers with one command
- **Least privilege security groups** — each instance only opens ports it needs

---

## Teardown

```bash
terraform destroy
```

Removes all 4 EC2 instances and both security groups cleanly.

---



**Chase Ealy** — Linux Infrastructure Engineer | RHCSA Certified  
[GitHub](https://github.com/chase-linux24) | [LinkedIn](https://www.linkedin.com/in/chase-ealy)

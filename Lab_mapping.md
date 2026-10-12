## Lab Mapping – Workbooks ↔ Black‑Hat‑Bash Machine Labs

The following table links each workbook (as defined in `Workbook_Subjects.md`) to the Docker‑based lab containers found in `~/Work/WV_Cyber_Cup_2026/Black-Hat-Bash/lab/machines/`.  For every workbook we list the most appropriate lab (or labs) and a short justification.  When no direct counterpart exists we note **None** and explain why.

| Workbook (subject) | Corresponding lab(s) | Why this lab matches (or why none) |
|-------------------|----------------------|-------------------------------------|
| **CH01_Enumeration – Enumeration** | **None** | The workbook focuses on generic network scanning with Nmap. The machine set only provides the services to be scanned, not a separate target host for enumeration. |
| **CH02_SMB_Reconnaissance – SMB Reconnaissance** | **None** | No SMB server is defined in `machines/`. |
| **CH03_SMB_Credential_Attacks – SMB Credential Attacks** | **None** | No SMB service is present. |
| **CH04_RDP_Exploitation – RDP Exploitation** | **None** | No Remote Desktop (RDP) service is provided. |
| **CH05_WinRM_Exploitation – WinRM Exploitation** | **None** | No Windows Remote Management endpoint exists. |
| **CH06_MSSQL_Exploitation – MSSQL Exploitation** | **c-db-02 (MySQL/MariaDB)** *potential* | The workbook targets Microsoft SQL Server, but the repo only ships a MariaDB/MySQL container (`c-db-02`). While the engine differs, concepts of service detection, version enumeration, credential brute‑force, and query execution can be demonstrated against this container. If a true MSSQL container is added later, it would be a perfect match. |
| **CH07_LDAP_Enumeration – LDAP Enumeration** | **None** | No LDAP server is included. |
| **CH08_Credential_Reuse – Credential Reuse** | **p-ftp-01**, **p-web-01**, **p-web-02** | This workbook teaches re‑using the same credentials across services. The FTP lab (`p-ftp-01`) and the two web labs (`p-web-01` – Flask app, `p-web-02` – WordPress) each have user accounts. Students can log in to FTP and then reuse those credentials on the Flask or WordPress sites, illustrating cross‑service reuse. |
| **CH09_Assessment – Assessment** | **p-jumpbox-01** (bastion) + *all other labs* | The assessment workbook combines enumeration, credential reuse, and exploitation. The jumpbox (`p-jumpbox-01`) serves as a bastion host for launching scans against the other containers, providing a realistic “full‑network assessment” scenario. |
| **CH_LIN01_Linux_Service_Enumeration – Linux Service Enumeration** | **c-backup-01** (HTTP + cron) + **p-jumpbox-01** (SSH) | Both containers expose typical Linux services (SSH on the jumpbox, HTTP on the backup container). Students can run Nmap against the jumpbox to discover the SSH service and against the backup container to discover the HTTP service, matching the enumeration steps. |
| **CH_LIN02_SSH_Authentication – SSH Authentication \& Discovery** | **p-jumpbox-01** (OpenSSH) | The jumpbox runs an OpenSSH server and creates a `backup` user with password `backup` (see its Dockerfile). This lab can be used for basic login, MOTD inspection, and post‑login user discovery exercises. |
| **CH_LIN03_SSH_Post‑Exploitation – SSH Post‑Exploitation** | **p-jumpbox-01** (SSH + sudo rights) | The jumpbox also grants sudo privileges to the `jmartinez` user via `jmartinez-user-sudo-config`. This enables privilege‑escalation, command execution, and file‑system discovery labs. |
| **CH_NET01_Log_Analysis – Log Analysis** | **c-backup-01** (cron‑generated HTTP logs) | The backup container runs a simple HTTP server launched by cron. Its access logs can be examined with standard Unix log‑analysis tools, providing a concrete example for the log‑analysis workbook. |
| **CH_NET02_PCAP_Forensics – PCAP Forensics** | **p-ftp-01** (FTP traffic) + **p-web-01** (Flask HTTP) | Both services generate network traffic that can be captured with `tcpdump` inside the Docker network. The resulting PCAP files give students material for credential extraction, SMTP‑style analysis, or HTTP session hijacking exercises. |
| **CH_NETSY12_Firewalls – Firewalls** | **None** (no dedicated firewall lab) | The base image (`Dockerfile-base`) installs `iptables` but does not configure a restrictive firewall. To cover this workbook you would need to add a container that applies explicit iptables rules (e.g., a firewall sandbox). |

### How to Use the Mapping
1. **Spin up the labs** – use the provided `docker‑compose.yml` (or run each `Dockerfile` manually) to bring up the containers. The service names (`p‑jumpbox‑01`, `p‑ftp‑01`, etc.) can be used as hostnames from within the Docker network.
2. **Adjust workbook commands** – replace any hard‑coded IPs or hostnames in the original workbooks with the Docker service names. For example, replace `nmap <target>` with `nmap p‑jumpbox‑01` or `nmap p‑ftp‑01`.
3. **Capture PCAPs** – while a lab is running, execute `docker exec <container> tcpdump -w /tmp/capture.pcap -i eth0` to collect traffic for the PCAP‑forensics workbook.
4. **Extend where needed** – labs marked **None** indicate gaps. You can create minimal containers that implement the missing services (SMB, LDAP, RDP, WinRM, MSSQL, firewall) and add them to `machines/` to achieve full coverage.

---
*Generated automatically from the workbook list and the current Black‑Hat‑Bash machine definitions.*
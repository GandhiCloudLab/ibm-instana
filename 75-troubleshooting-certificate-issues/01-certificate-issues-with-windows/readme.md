# Instana TLS/SSL Certificate - Troubleshooting

## Certificate Verification Commands

### **Kubernetes Commands**

**List all certificates:**
```bash
kubectl get certificates --all-namespaces
```

**Check certificate details:**
```bash
kubectl get certificate agent-acceptor-tls -n instana-core -o yaml
```

**Extract certificate from secret:**
```bash
# Get the certificate
kubectl get secret instana-tls -n instana-core -o jsonpath='{.data.tls\.crt}' | base64 -d > instana-backend.crt

# Get the CA certificate (if present)
kubectl get secret instana-tls -n instana-core -o jsonpath='{.data.ca\.crt}' | base64 -d > instana-ca.crt

# Get the private key (for backend only, never share)
kubectl get secret instana-tls -n instana-core -o jsonpath='{.data.tls\.key}' | base64 -d > instana-backend.key
```

**Check PKCS12 keystore:**
```bash
# Get keystore from pod
kubectl exec -n instana-core <acceptor-pod-name> -- cat /etc/instana_tls/acceptor.keystore > acceptor.keystore

# List contents (requires password)
keytool -list -v -keystore acceptor.keystore -storetype PKCS12
```

### **OpenSSL Commands**

**View certificate details:**
```bash
openssl x509 -in instana-backend.crt -text -noout
```

**Check certificate dates:**
```bash
openssl x509 -in instana-backend.crt -noout -dates
```

**Verify certificate chain:**
```bash
openssl verify -CAfile instana-ca.crt instana-backend.crt
```

**Test TLS connection:**
```bash
openssl s_client -connect agent-acceptor.xxxxxxx.instana.co.in:443 -showcerts
```

**Extract certificate from server:**
```bash
echo | openssl s_client -connect agent-acceptor.xxxxxxx.instana.co.in:443 2>/dev/null | openssl x509 -out server-cert.pem
```

### **Windows PowerShell Commands**

**List certificates in store:**
```powershell
# List all root CAs
Get-ChildItem -Path Cert:\LocalMachine\Root

# Search for Instana certificates
Get-ChildItem -Path Cert:\LocalMachine\Root | Where-Object {$_.Subject -like "*Instana*"}
```

**Import certificate:**
```powershell
# Import to Trusted Root CA store
Import-Certificate -FilePath "instana-ca.crt" -CertStoreLocation Cert:\LocalMachine\Root

# Verify import
Get-ChildItem -Path Cert:\LocalMachine\Root | Where-Object {$_.Subject -like "*Instana*"}
```

**Test connection:**
```powershell
# Test TLS connection
Test-NetConnection -ComputerName agent-acceptor.xxxxxxx.instana.co.in -Port 443

# Test with certificate validation
$url = "https://agent-acceptor.xxxxxxx.instana.co.in"
try {
    $response = Invoke-WebRequest -Uri $url -UseBasicParsing
    Write-Host "✅ Connection successful"
} catch {
    Write-Host "❌ Connection failed: $($_.Exception.Message)"
}
```

**View certificate from file:**
```powershell
# View certificate details
$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2("instana-backend.crt")
$cert | Format-List *
```

### **curl Commands**

**Test with certificate validation:**
```bash
# Will fail if certificate not trusted
curl -v https://agent-acceptor.xxxxxxx.instana.co.in

# Skip certificate validation (for testing only)
curl -k https://agent-acceptor.xxxxxxx.instana.co.in

# Use specific CA certificate
curl --cacert instana-ca.crt https://agent-acceptor.xxxxxxx.instana.co.in
```

---

## **Solutions & Best Practices**

### Import Root CA Certificate (Recommended)

**1. Extract Root CA from Kubernetes:**
```bash
# Connect to Kubernetes cluster
kubectl get secret instana-tls -n instana-core -o jsonpath='{.data.tls\.crt}' | base64 -d > instana-backend.crt

# If CA is separate
kubectl get secret instana-tls -n instana-core -o jsonpath='{.data.ca\.crt}' | base64 -d > instana-ca.crt
```

**2. Transfer to Windows Agent Machine:**
```bash
# Using SCP
scp instana-ca.crt user@windows-agent-host:C:\temp\

# Or copy via shared folder, USB, etc.
```

**3. Import on Windows:**
```powershell
# Open PowerShell as Administrator
Import-Certificate -FilePath "C:\temp\instana-ca.crt" -CertStoreLocation Cert:\LocalMachine\Root

# Verify import
Get-ChildItem -Path Cert:\LocalMachine\Root | Where-Object {$_.Subject -like "*Instana*"}
```

**4. Restart Instana Agent:**
```powershell
Restart-Service "Instana Agent Service"
```

**5. Verify Connection:**
```powershell
# Check agent logs
Get-Content "C:\Program Files\Instana\instana-agent\data\log\agent.log" -Wait -Tail 50

# Look for successful connection messages
```
---
## **Debugging Steps**

**1. Verify Certificate on Server:**
```bash
kubectl exec -n instana-core <acceptor-pod> -- ls -la /etc/instana_tls/
```

**2. Check Certificate Details:**
```bash
kubectl get secret instana-tls -n instana-core -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -text -noout
```

**3. Test from Client:**
```bash
openssl s_client -connect agent-acceptor.xxxxxxx.instana.co.in:443 -showcerts
```

**4. Check Agent Logs:**
```powershell
Get-Content "C:\Program Files\Instana\instana-agent\data\log\agent.log" -Tail 100
```

**5. Verify DNS Resolution:**
```powershell
nslookup agent-acceptor.xxxxxxx.instana.co.in
```
---

## Quick Reference

### **Certificate Extraction (One-Liner)**
```bash
kubectl get secret instana-tls -n instana-core -o jsonpath='{.data.tls\.crt}' | base64 -d > instana-backend.crt
```

### **Certificate Import (Windows)**
```powershell
Import-Certificate -FilePath "instana-backend.crt" -CertStoreLocation Cert:\LocalMachine\Root
```

### **Verify Connection**
```bash
openssl s_client -connect agent-acceptor.xxxxxxx.instana.co.in:443 < /dev/null
```

### **Check Certificate Expiration**
```bash
openssl x509 -in instana-backend.crt -noout -enddate
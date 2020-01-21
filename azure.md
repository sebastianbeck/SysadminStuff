# Azure VM types
<table>
<thead>
<tr>
<th>Type</th>
<th>Sizes</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr>
<td>General purpose</td>
<td>Dsv3, Dv3, DSv2, Dv2, DS, D, Av2, A0-7</td>
<td>Balanced CPU-to-memory. Ideal for dev/test and small to medium applications and data solutions.</td>
</tr>
<tr>
<td>Compute optimized</td>
<td>Fs, F</td>
<td>High CPU-to-memory. Good for medium-traffic applications, network appliances, and batch processes.</td>
</tr>
<tr>
<td>Memory optimized</td>
<td>Esv3, Ev3, M, GS, G, DSv2, DS, Dv2, D</td>
<td>High memory-to-core. Great for relational databases, medium to large caches, and in-memory analytics.</td>
</tr>
<tr>
<td>Storage optimized</td>
<td>Ls</td>
<td>High disk throughput and IO. Ideal for big data, SQL, and NoSQL databases.</td>
</tr>
<tr>
<td>GPU optimized</td>
<td>NV, NC</td>
<td>Specialized VMs targeted for heavy graphic rendering and video editing.</td>
</tr>
<tr>
<td>High performance</td>
<td>H, A8-11</td>
<td>Our most powerful CPU VMs with optional high-throughput network interfaces (RDMA).</td>
</tr>
</tbody>
</table>

## Create VN
```
az network vnet create \
    --resource-group $rg \
    --name MyVNet1 \
    --address-prefix 10.10.0.0/16 \
    --subnet-name FrontendSubnet \
    --subnet-prefix 10.10.1.0/24 \
    --location West
```
    
## Create Subnet
```
az network vnet subnet create \
    --address-prefixes 10.10.2.0/24 \
    --name BackendSubnet \
    --resource-group $rg \
    --vnet-name MyVNet1
```
## Create Ubuntu Test Machne
```
az vm create \
    --resource-group $rg \
    --name FrotendVM \
    --vnet-name MyVNet1 \
    --subnet FrontendSubnet \
    --image UbuntuLTS \
    --admin-username azureuser \
    --admin-password <password>
```
## Create NSG
```
az network nsg create \
    --name MyNsg \
    --resource-group $rg \
    --location EastUS
```  
##Create NSG Rule 
```
az network nsg rule create \
    --resource-group $rg \
    --name MyNSGRule \
    --nsg-name MyNsg \
    --priority 4096 \
    --source-address-prefixes 10.10.2.0/24 \
    --source-port-ranges 80 443 3389 \
    --destination-address-prefixes '*' \
    --destination-port-ranges 80 443 3389 \
    --access Deny \
    --protocol TCP \
    --description "Deny from specific IP address ranges on 80, 443 and 3389."
```

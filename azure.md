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

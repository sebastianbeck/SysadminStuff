## Create VN
az network vnet create \
    --resource-group $rg \
    --name MyVNet1 \
    --address-prefix 10.10.0.0/16 \
    --subnet-name FrontendSubnet \
    --subnet-prefix 10.10.1.0/24 \
    --location EastUS
    
## Create Subnet
az network vnet subnet create \
    --address-prefixes 10.10.2.0/24 \
    --name BackendSubnet \
    --resource-group $rg \
    --vnet-name MyVNet1
    
## Create Ubuntu Test Machne
az vm create \
    --resource-group $rg \
    --name FrotendVM \
    --vnet-name MyVNet1 \
    --subnet FrontendSubnet \
    --image UbuntuLTS \
    --admin-username azureuser \
    --admin-password <password>
    
    rg=learn-69aeefe3-1a51-4715-8ea7-6da97ba8a76a

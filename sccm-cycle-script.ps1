$ComputerName=ws01013.scottlogic.co.uk

Invoke-CMClientCycle -ComputerName $ComputerName -Cycle Application_Deployment_Evaluation
Invoke-CMClientCycle -ComputerName $ComputerName -Cycle Discovery_Data_Collection
Invoke-CMClientCycle -ComputerName $ComputerName -Cycle File_Collection
Invoke-CMClientCycle -ComputerName $ComputerName -Cycle Hardware_Inventory
Invoke-CMClientCycle -ComputerName $ComputerName -Cycle Machine_Policy_Retrieval_and_Evaluation
Invoke-CMClientCycle -ComputerName $ComputerName -Cycle Software_Inventory
Invoke-CMClientCycle -ComputerName $ComputerName -Cycle Software_Metering_Usage_Report
Invoke-CMClientCycle -ComputerName $ComputerName -Cycle Software_Updates_Deployment_Evaluation
Invoke-CMClientCycle -ComputerName $ComputerName -Cycle Software_Updates_Scan
Invoke-CMClientCycle -ComputerName $ComputerName -Cycle User_Policy_Retrieval_and_Evaluation
Invoke-CMClientCycle -ComputerName $ComputerName -Cycle Windows_Installer_Source_List_Update
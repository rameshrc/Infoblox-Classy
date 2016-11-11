<#
.Synopsis
	New-IBExtensibleAttributeDefinition creates an extensible attribute definition in the Infoblox database.
.DESCRIPTION
	New-IBExtensibleAttributeDefinition creates an extensible attribute definition in the Infoblox database.  This can be used as a reference for assigning extensible attributes to other objects.
.PARAMETER Gridmaster
	The fully qualified domain name of the Infoblox gridmaster.  SSL is used to connect to this device, so a valid and trusted certificate must exist for this FQDN.
.PARAMETER Credential
	Powershell credential object for use in authentication to the specified gridmaster.  This username/password combination needs access to the WAPI interface.
.PARAMETER Name
	The Name of the new extensible attribute definition.
.PARAMETER Type
    The type definition for the extensible attribute.  This defines the type of data that can be provided as a value when assigning an extensible attribute to an object.
    Valid values are:
        •DATE
        •EMAIL
        •ENUM
        •INTEGER
        •STRING
        •URL
.PARAMETER DefaultValue
    The default value to assign to the extensible attribute if no value is selected.  This applies when assigning an extensible attribute to an object.
.PARAMETER Comment
	Optional comment field for the object.  Can be used for notation and keyword searching by Get- cmdlets.
.EXAMPLE
	New-IBExtensibleAttributeDefinition -Gridmaster $Gridmaster -Credential $Credential -Name Site -Type String -defaultValue CORP

    This example creates an extensible attribute definition for assigned a site attribute to an object.
.INPUTS
	System.String
	IB_ReferenceObject
.OUTPUTS
	IB_ExtAttrsDef
#>
Function New-IBExtensibleAttributeDefinition {
    [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact="High")]
    Param(
        [Parameter(Mandatory=$True)]
        [ValidateScript({If($_){Test-IBGridmaster $_ -quiet}})]
        [ValidateNotNullorEmpty()]
        [String]$Gridmaster,

        [Parameter(Mandatory=$True)]
        [System.Management.Automation.Credential()]
		$Credential,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullorEmpty()]
        [String]$Name,

        [Parameter(Mandatory=$True)]
        [ValidateSet('Date','Email','Enum','Integer','String','URL')]
        [String]$Type,

        [String]$DefaultValue,

        [String]$Comment

    )
    BEGIN{
        $FunctionName = $pscmdlet.MyInvocation.InvocationName.ToUpper()
        write-verbose "$FunctionName`:  Beginning Function"
        Write-Verbose "$FunctionName`:  Connecting to Infoblox device $gridmaster to retrieve Views"
        Try {
            $IBViews = Get-IBView -Gridmaster $Gridmaster -Credential $Credential -Type DNSView
        } Catch {
            Write-error "Unable to connect to Infoblox device $gridmaster.  Error code:  $($_.exception)" -ea Stop
        }
        If ($View){
            Write-Verbose "$FunctionName`:  Validating View parameter against list from Infoblox device"
            If ($IBViews.name -cnotcontains $View){
                $ViewList = $ibviews.name -join ', '
                write-error "Invalid data for View parameter.  Options are $ViewList" -ea Stop
            }
        }

    }
    PROCESS{
        If ($pscmdlet.ShouldProcess($Name)){
            $output = [IB_ExtAttrsDef]::Create($Gridmaster, $Credential, $Name, $Type, $Comment, $DefaultValue)
            $output
        }
    }
    END{}
}

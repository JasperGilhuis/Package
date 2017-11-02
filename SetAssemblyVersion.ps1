#
#
# This script Parses Build Version numbers
# It expects version numbers following a pattern
# BuildNumber should look like $(BuildDefinitionName)_$(Date:yyyyMMdd)$(Rev:.r)
# Assembly numbers expected in pattern 1.0.C.D 
#
#

	Param
	(
	 	[Parameter(Mandatory=$True)] [string]$AssemblyVersion, 
		[Parameter(Mandatory=$True)] [string]$AssemblyFileVersion
	)

	# write parameters
    Write-Host("** Received Parameters **")
    Write-Host("  AssemblyVersion : ["+$AssemblyVersion+"]") 
	Write-Host("  AssemblyFileVersion : ["+$AssemblyFileVersion+"]")
    Write-Host("** End Received Parameters **") 

    $BuildNumber = $env:BUILD_BUILDNUMBER

    # version numbers
	$parts = $BuildNumber.Split('_')
	$dateFromBuild = $BuildNumber.Split('_')[$parts.Length -1] # returns 20171031.9

	# splitting
	$yeari = $dateFromBuild.Substring(2, 2) # year part 10 from 2017
    $monthi = $dateFromBuild.Substring(4, 2) # month part 10
    $dayi = $dateFromBuild.Substring(6, 2) # day 31
    $revision = $dateFromBuild.Substring(9).PadLeft(3, '0') # revision part 9 or 10 or 11 etc.

	# concats
	$ym = $yeari + $monthi 
	$dr = $dayi + $revision            
	
	# parse the assembly version numbers based on expected template
	$assemblyVersion = $AssemblyVersion.Replace("C", $ym).Replace("D", $dr)
    $assemblyFileVersion = $AssemblyFileVersion.Replace("C", $ym).Replace("D", $dr)

	# write determined numbers
	Write-Host("Determined Assembly Version : ["+$assemblyVersion+"]")
	Write-Host("Determined Assembly File Version : ["+$assemblyFileVersion+"]")
	
	
	$AgentID = $env:AGENT_ID
	
    #Set Enviroment Variables
    [Environment]::SetEnvironmentVariable("SYSTEM_ASSEMBLY_VERSION_$AgentID", "$assemblyVersion", "User")
    [Environment]::SetEnvironmentVariable("SYSTEM_ASSEMBLY_FILE_VERSION_$AgentID", "$assemblyFileVersion", "User")


Write-Host "##vso[task.setvariable variable=SYSTEM_ASSEMBLY_VERSION]$assemblyVersion"
Write-Host "##vso[task.setvariable variable=SYSTEM_ASSEMBLY_FILE_VERSION]$assemblyFileVersion"

	# find all AssemblyInfo.* files
	$AllVersionFiles = Get-ChildItem $env:BUILD_SOURCESDIRECTORY AssemblyInfo.* -recurse

	foreach ($file in $AllVersionFiles) 
    { 
        Write-Host "== Updating AssemblyInfo File == " + $file.FullName

		# remove the read-only bit on the file
        Set-ItemProperty $file.FullName IsReadOnly $false

		$tmpFile = $file.FullName + ".tmp"

		get-content $file.FullName | 
        %{$_ -replace 'AssemblyVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)', "AssemblyVersion(""$AssemblyVersion"")" } |
        %{$_ -replace 'AssemblyFileVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)', "AssemblyFileVersion(""$AssemblyFileVersion"")" } |
		%{$_ -replace 'AssemblyInformationalVersion\(""\)', "AssemblyInformationalVersion(""$BuildNumber"")" }  | out-file -filePath $tmpFile -encoding UTF8 -force

		move-item $TmpFile $file.FullName -force
    }



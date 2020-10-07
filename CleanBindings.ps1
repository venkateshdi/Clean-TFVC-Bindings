function RemoveProjectBindings() {
    # Get all Visual Studio .*proj files and add filenames to list
    $projectFiles = Get-Childitem -Recurse -Filter *.*proj | ForEach-Object FullName
    $succeeded = 0

    Write-Host "Cleaning project files..."
    foreach ($projectFile in $projectFiles) {
        Write-Host "$projectFile... " -NoNewLine

        # common xml namespace for VS project 
        $projectNamespace = @{ ns="http://schemas.microsoft.com/developer/msbuild/2003"; };
        [xml]$projectXml = [xml](Get-Content $projectFile)

        # get all xml nodes starting with Scc
        $sccInfoNodes = $projectXml | Select-XML -Xpath "//ns:PropertyGroup/*[contains(local-name(), 'Scc')]" -Namespace $projectNamespace
        if ($sccInfoNodes.Count -gt 0) {
            foreach ($sccInfo in $sccInfoNodes) {
                # get parent node
                $sccParent = $sccINfo.Node.ParentNode

                # then remove Scc node from parent node
                $sccParent.RemoveChild($sccInfo.Node) | Out-Null
            }
            
            # Save project file
            $projectXml.Save($projectFile)
            Write-Host "Success"
            $succeeded++
        }
        else {
            Write-Host "Not Found"
        }
    }

    Write-Host "$succeeded/$($projectFiles.Count) files processed.`n"
}

function RemoveSolutionBindings() {
    # Get all Visula Studio .sln files and add filenames to list
    $solutionFiles = Get-Childitem -Recurse -Filter *.sln | ForEach-Object FullName
    $succeeded = 0

    Write-Host "Cleaning solution files..."
    foreach ($solutionFile in $solutionFiles) {
        # regular expression to find parent section
        [regex]$parentExp = "(`t+\w+\(TeamFoundationVersionControl\)(.)+p(\w)+Solution)(\W)+(EndGlobalSection)"
        
        # regular expression to find child SCC information
        [regex]$childExp = "((`t)+Scc(.)+)`n"

        Write-Host "$solutionFile... " -NoNewLine
        $solutionText = Get-Content $solutionFile -Raw
        
        # check if bindings available
        $found = $solutionText -match "(`t+\w+\(TeamFoundationVersionControl\)(.)+p(\w)+Solution)(\W)+"
        if($found) {
            # Remove child elements
            $result = $solutionText -replace $childExp, ""
            
            # then cleanup globalsection
            $result = $result -replace $parentExp, ""

            # Save cleaned up text to file
            Set-Content -Path $solutionFile -Value $result
            Write-Host "Success"
            $succeeded++
        }
        else {
            Write-Host "Not Found"
        }
    }

    Write-Host "$succeeded/$($solutionFiles.Count) files processed.`n"
}

Write-Host "Started cleaning up TFVC bindings...`n"
# Clean up project files
RemoveProjectBindings

# Clean up solution files
RemoveSolutionBindings
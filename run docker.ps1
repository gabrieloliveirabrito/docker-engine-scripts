$BoxName = "box"

$Status=$(docker-machine status $BoxName)

if ($Status -eq "Stopped") {
    Write-Output "Starting docker machine $($BoxName)"
    docker-machine start $BoxName
} else {
    Write-Output "Restarting docker machine $($BoxName)"
    docker-machine restart $BoxName
}

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to execute docker-machine command, exitcode = $($LASTEXITCODE) aborting..."
    Exit -1
}

docker-machine regenerate-certs $BoxName --force
$BoxEnvs=$(docker-machine env $BoxName)

foreach ($env in $BoxEnvs) {
    if ($env.StartsWith('$Env:')) {
        $envVals = $($env -replace '"',' ').SubString($env.IndexOf(":") + 1).Split(" = ", [System.StringSplitOptions]::RemoveEmptyEntries)

        $envName = $envVals[0]
        $envValue = $envVals[1]

        Write-Output "Setting variable $($envName)"
        [Environment]::SetEnvironmentVariable($envName, $envValue, [System.EnvironmentVariableTarget]::User)
    }
}
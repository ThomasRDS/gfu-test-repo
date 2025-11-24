# Lösch all Branches, die bereits jemergt sin
# Dat Skript lösch all lokale Branches, die in den Default-Branch jemergt sin

# Hol dir den aktuelle Branch
$currentBranch = git rev-parse --abbrev-ref HEAD

# Hol dir den Default-Branch (meistens main oder master)
$defaultBranch = git symbolic-ref refs/remotes/origin/HEAD | ForEach-Object { $_ -replace 'refs/remotes/origin/', '' }

# Stell sicher, dat mir op dem Default-Branch sin
if ($currentBranch -ne $defaultBranch) {
    Write-Host "Wechsel op den Default-Branch: $defaultBranch" -ForegroundColor Yellow
    git checkout $defaultBranch
}

# Hol die neueste Version vum Remote
Write-Host "Hol die neueste Version vom Remote..." -ForegroundColor Cyan
git fetch --prune

# Hol all jemergte Branches (ohne den aktuelle und den Default-Branch)
$mergedBranches = git branch --merged | Where-Object { 
    $branch = $_.Trim()
    $branch -notmatch '^\*' -and 
    $branch -ne $defaultBranch -and 
    $branch -ne "master" -and 
    $branch -ne "main"
}

if ($mergedBranches.Count -eq 0) {
    Write-Host "Et jitt kein jemergte Branches zum Lösche." -ForegroundColor Green
} else {
    Write-Host "`nFolgende Branches wäde jelöscht:" -ForegroundColor Yellow
    $mergedBranches | ForEach-Object { Write-Host "  - $($_.Trim())" }
    
    $confirmation = Read-Host "`nWillt de die Branches wirklich lösche? (j/n)"
    
    if ($confirmation -eq 'j' -or $confirmation -eq 'J') {
        foreach ($branch in $mergedBranches) {
            $branchName = $branch.Trim()
            Write-Host "Lösch Branch: $branchName" -ForegroundColor Red
            git branch -d $branchName
        }
        Write-Host "`nAll jemergte Branches sin jelöscht!" -ForegroundColor Green
    } else {
        Write-Host "Lösche wurd afjebroche." -ForegroundColor Yellow
    }
}

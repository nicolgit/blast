winget install --id=Gyan.FFmpeg

Clear-Host

Remove-Item ../video/*.mp4 
Remove-Item ../video/*.gif 

function Convert-JpegsToGif {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SourceDir,
        [Parameter(Mandatory = $true)]
        [string]$OutputDir,
        [Parameter(Mandatory = $true)]
        [string]$OutputFileName,
        [Parameter(Mandatory = $true)]
        [float]$FramesPerSecond
    )
    
    $inputPattern = Join-Path $SourceDir "img-%02d.png"
    $outputMp4 = Join-Path $OutputDir "$OutputFileName.mp4"
    $outputGif = Join-Path $OutputDir "$OutputFileName.gif"

    write-output xx $inputPattern
    write-output xx $outputMp4
    write-output xx $outputGif

    ffmpeg -framerate $FramesPerSecond -i $inputPattern -c:v libvpx-vp9 -lossless 1 -vf "scale=603:1311" -y $outputMp4
    $palette = "palette.png"
    $filters = "fps=12,scale=1072:-1:flags=lanczos"
    ffmpeg -v warning -i $outputMp4 -vf "$filters,palettegen" -y $palette
    ffmpeg -v warning -i $outputMp4 -i $palette -lavfi "$filters [x]; [x][1:v] paletteuse" -y $outputGif
    Remove-Item $palette
    Remove-Item $outputMp4
}

Convert-JpegsToGif -SourceDir "ios" -OutputDir "../video" -OutputFileName "ios" -FramesPerSecond 0.5
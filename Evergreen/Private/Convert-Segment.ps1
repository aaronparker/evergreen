function Convert-Segment {
    param (
        [System.String] $Segment
    )

    if ($Segment -match '^\d+$') {
        return [System.Int32]$Segment
    }
    else {
        $Normalized = 0
        foreach ($Char in $Segment.ToCharArray()) {
            $Normalized = $Normalized * 100 + [System.Int32][System.Char]$Char
        }
        return $Normalized
    }
}

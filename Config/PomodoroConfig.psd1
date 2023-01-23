$config = @{
    activeTime = 0
    breakTime = 0
    amountPomodoros = 0
    pomodoroPreviews = 3
    sounds = @{
        default = @{
            start = "biggie-baka-baka-baka.wav"
            break = "the-fire-roots.wav"
            end = "the-remorse-drake.wav"
        }
    }
    options = @(
        @{ activeTime = 0.15; breakTime = 0.15 }
        @{ activeTime = 25; breakTime = 5 }
        @{ activeTime = 50; breakTime = 10 }
    )
}
﻿using System;
using System.Timers;

namespace AppCommon
{
    internal class CommonTimer
    {
        // タイマーオブジェクト
        private readonly Timer Timer = null!;

        // タイムアウトイベント
        public delegate void CommandTimeoutEventHandler(object sender, EventArgs e);
        public event CommandTimeoutEventHandler CommandTimeoutEvent = null!;

        // タイマー名称
        //（個別のタイマースレッドを識別するための名称）
        private readonly string TimerName;

        // 応答タイムアウト監視制御
        private bool TimerStarted = false;

        public CommonTimer(string n, int ms)
        {
            TimerName = n;
            Timer = new Timer(ms);
        }

        public void Start()
        {
            if (TimerStarted) {
                return;
            }
            TimerStarted = true;
            Timer.Elapsed += CommandTimerElapsed;
            Timer.Start();
        }

        public void Stop()
        {
            if (TimerStarted == false) {
                return;
            }
            TimerStarted = false;
            Timer.Stop();
            Timer.Elapsed -= CommandTimerElapsed;
        }

        private void CommandTimerElapsed(object? sender, EventArgs e)
        {
            if (sender == null) {
                return;
            }

            try {
                // イベントを送出
                CommandTimeoutEvent(sender, e);

            } catch (Exception ex) {
                AppLogUtil.OutputLogError(string.Format("CommonTimer({0}): {1}", TimerName, ex.Message));

            } finally {
                Stop();
            }
        }
    }
}

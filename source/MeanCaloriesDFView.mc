import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Attention;

class WalkingData{
    hidden const time_warming = 180;
    hidden const target_sec_per_m = ((7 * 60) + 55) / 1000.0f;

    hidden var fit_file;
    hidden var seconds_above_target as Number = 0;

    function initialize(fit_handler as FitHandler){
        fit_file = fit_handler;
    }

    function getColor(){
        if(seconds_above_target > 0){
            return Graphics.COLOR_RED;
        }
        else if(seconds_above_target < 0){
            return Graphics.COLOR_GREEN;
        }
        else{
            return Graphics.COLOR_WHITE;
        }
    }

    function addMeasurment(meters as Number, seconds as Number){
        var expected_seconds = target_sec_per_m * meters;
        seconds_above_target = (seconds - expected_seconds).toNumber();
        if(seconds > time_warming && seconds_above_target < 0){
            vibrate();
        }
        fit_file.setData(seconds_above_target);
    }

    function getDisplayStr(){
        return seconds_above_target.abs().toString();
    }

    function vibrate(){
        if (!(Attention has :vibrate)) {
            return;
        }

        var vibeData =
        [
            new Attention.VibeProfile(90, 200),
        ];
        Attention.vibrate(vibeData);
    }
}

class CyclkingData{
    hidden const time_warming = 120;
    hidden const resting_hr = 90;
    hidden const target_cycle_hr = 150;
    hidden const cycleking_session_time = 3600;
    hidden const hr_sum_to_achive = (cycleking_session_time - time_warming) * (target_cycle_hr - resting_hr);

    hidden var hr_sum = 0;
    hidden var seconds_counter = 0;
    hidden var last_noted_second = 0;
    hidden var mean_hr = 0.0f;
    hidden var cyckling_hr_percentage = 0.0f;

    hidden var fit_file;

    function initialize(fit_handler as FitHandler){
        fit_file = fit_handler;
    }

    function addMeasurment(hr as Number, second as Number){
        if(second > last_noted_second && hr > 0 && second > time_warming){
            last_noted_second = second;
            hr_sum += (hr - resting_hr);
            seconds_counter +=1;
        }else{
            fit_file.setData(0);
            return;
        }

        fit_file.setData(getHrAboveTarget());
        mean_hr = (1.0 * hr_sum / seconds_counter) + resting_hr;
        cyckling_hr_percentage = 100.0 *  hr_sum / hr_sum_to_achive;
    }

    private function getHrAboveTarget(){
        return hr_sum - (seconds_counter * (target_cycle_hr - resting_hr));
    }

    function getDisplayStr(){
        var text = mean_hr.toNumber() + "\n(" + cyckling_hr_percentage.format("%.2f") + "%)";
        return text;
    }

    function getColor(){
        if(mean_hr < target_cycle_hr){
            return Graphics.COLOR_RED;
        }
        else if(mean_hr > target_cycle_hr){
            return Graphics.COLOR_GREEN;
        }
        else{
            return Graphics.COLOR_WHITE;
        }
    }
}

class MeanCaloriesDFView extends WatchUi.DataField {
    //general
    hidden var is_walking as Boolean = true;
    hidden var fit_handler as FitHandler;
    hidden var cyckle_data as CyclkingData? = null;
    hidden var walking_data as WalkingData? = null;

    //UI
    hidden var value_label as WatchUi.Text? = null;

    function initialize() {
        DataField.initialize();
        is_walking = Activity.getProfileInfo().sport != Activity.SPORT_CYCLING;
        fit_handler = new FitHandler(me, is_walking);
        if(is_walking){
            walking_data = new WalkingData(fit_handler);
        }else{
            cyckle_data = new CyclkingData(fit_handler);
        }
    }

    function onLayout(dc as Dc) as Void {
        setLayout( Rez.Layouts.MainLayout( dc ) );
        value_label = View.findDrawableById("value_label") as Text;
        value_label.locX = 0.5f * dc.getWidth();
        value_label.locY = 0.5f * dc.getHeight();
    }

    function compute(info as Activity.Info) as Void {
        var second = info.elapsedTime == null ? 1 : (info.elapsedTime / 1000.0).toNumber();

        if(is_walking){
            var meters = info.elapsedDistance  == null ? 0 : info.elapsedDistance.toNumber();
            walking_data.addMeasurment(meters, second);
        }
        else{
            var hr = info.currentHeartRate == null ? 0 : info.currentHeartRate;
            cyckle_data.addMeasurment(hr, second);
        }
    }

    function onUpdate(dc as Dc) as Void {    
        var color = is_walking ? walking_data.getColor() : cyckle_data.getColor();
        var text = is_walking ? walking_data.getDisplayStr() : cyckle_data.getDisplayStr();
        value_label.setColor(color);
        value_label.setText(text);
        View.onUpdate(dc);
    }
}
using Toybox.FitContributor as FFile;
import Toybox.WatchUi;
import Toybox.Lang;
class FitHandler{
    private var field;

    function initialize(df as WatchUi.DataField, is_walking as Boolean) {
        // _mFITFuelRecord = self.createField(Ui.loadResource(Rez.Strings.FieldCurrent), 0, Fit.DATA_TYPE_FLOAT,
        //     { :mesgType => Fit.MESG_TYPE_RECORD, :units => _mCalorieValues[_mPropFuelType][1] });
        // _mFITFuelLap = self.createField(Ui.loadResource(Rez.Strings.FieldCurrent), 1, Fit.DATA_TYPE_FLOAT,
        //     { :mesgType => Fit.MESG_TYPE_LAP, :units => _mCalorieValues[_mPropFuelType][1] });
        var title = "Wookie-chart";// WatchUi.loadResource(Rez.Strings.oxy_chart_label);
        var unit = is_walking ? " s" : " HR";

        field = df.createField(title, 0, FFile.DATA_TYPE_SINT32,
            { :mesgType => FFile.MESG_TYPE_RECORD, :units => unit });
    }

    function setData(value as Number){
        field.setData(value);
    }
}


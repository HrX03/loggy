package hrx.loggy;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.util.Log;
import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

public class LoggyPlugin implements FlutterPlugin, MethodCallHandler {
  private Context context;
  private MethodChannel channel;
  private String packageName;

  public LoggyPlugin() {
    this(null);
  }

  public LoggyPlugin(Context context) {
    this.context = context;
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "loggy");
    context = flutterPluginBinding.getApplicationContext();
    channel.setMethodCallHandler(this);
  }
  
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "loggy");
    channel.setMethodCallHandler(new LoggyPlugin(registrar.context()));
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("log")) {
      String tag = call.argument("tag");
      int level = call.argument("level");
      String message = call.argument("message");

      if(tag == null) tag = getAppLabel();

      switch(level) {
        case Log.VERBOSE:
          Log.v(tag, message);
          break;
        case Log.DEBUG:
          Log.d(tag, message);
          break;
        case Log.INFO:
          Log.i(tag, message);
          break;
        case Log.WARN:
          Log.w(tag, message);
          break;
        case Log.ERROR:
          Log.e(tag, message);
          break;
        case 7:
          Log.wtf(tag, message);
          break;
        default:
          throw new IllegalArgumentException("Invalid log level");
      }

      result.success(null);
    } else if(call.method.equals("appLabel")) {
      result.success(getAppLabel());
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  private String getAppLabel() {
    PackageManager pm = context.getPackageManager();
    PackageInfo info;
    try {
      info = pm.getPackageInfo(context.getPackageName(), 0);
    } catch (NameNotFoundException e) {
      return "Application";
    }

    return info.applicationInfo.loadLabel(pm).toString();
  }
}
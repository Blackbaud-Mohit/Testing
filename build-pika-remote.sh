#!/bin/bash
set -e

WORK_DIR="$HOME/Downloads/pika-remote-helper"
ADB="/Users/mohit/Downloads/platform-tools/adb"
APKTOOL="/opt/homebrew/bin/apktool"

echo "==> Creating PikaRemoteHelper project in $WORK_DIR ..."
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR/src/res/xml"
mkdir -p "$WORK_DIR/src/ res/values"
rm -rf "$WORK_DIR/src/ res"
mkdir -p "$WORK_DIR/src/res/values"
mkdir -p "$WORK_DIR/src/smali/com/mohit/pikaremote"

cat > "$WORK_DIR/src/apktool.yml" << 'EOF'
version: 3.0.3
apkFileName: PikaRemoteHelper.apk
isFrameworkApk: false
usesFramework:
  ids:
  - 1
  tag: null
sdkInfo:
  minSdkVersion: 24
  targetSdkVersion: 28
packageInfo:
  forcedPackageId: 127
  renameManifestPackage: null
versionInfo:
  versionCode: 1
  versionName: "1.0"
sharedLibrary: false
sparseResources: false
compactEntries: false
doNotCompress:
- resources.arsc
EOF

cat > "$WORK_DIR/src/AndroidManifest.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.mohit.pikaremote"
    android:compileSdkVersion="28"
    android:compileSdkVersionCodename="9"
    platformBuildVersionCode="28"
    platformBuildVersionName="9">
    <application android:label="PikaRemoteHelper">
        <service
            android:name="com.mohit.pikaremote.PikaRemoteService"
            android:label="PikaRemoteHelper"
            android:permission="android.permission.BIND_ACCESSIBILITY_SERVICE"
            android:exported="true">
            <intent-filter>
                <action android:name="android.accessibilityservice.AccessibilityService" />
            </intent-filter>
            <meta-data
                android:name="android.accessibilityservice"
                android:resource="@xml/service_config" />
        </service>
    </application>
</manifest>
EOF

cat > "$WORK_DIR/src/res/xml/service_config.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<accessibility-service xmlns:android="http://schemas.android.com/apk/res/android"
    android:accessibilityEventTypes="typeWindowStateChanged"
    android:accessibilityFeedbackType="feedbackGeneric"
    android:accessibilityFlags="flagDefault|flagIncludeNotImportantViews|flagReportViewIds|flagRequestFilterKeyEvents|flagRetrieveInteractiveWindows"
    android:canPerformGestures="true"
    android:canRequestFilterKeyEvents="true"
    android:canRetrieveWindowContent="true"
    android:notificationTimeout="50" />
EOF

cat > "$WORK_DIR/src/res/values/public.xml" << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <public type="xml" name="service_config" id="0x7f010000" />
</resources>
EOF

cat > "$WORK_DIR/src/smali/com/mohit/pikaremote/PikaRemoteService.smali" << 'EOF'
.class public Lcom/mohit/pikaremote/PikaRemoteService;
.super Landroid/accessibilityservice/AccessibilityService;
.implements Ljava/lang/Runnable;

.field private curSec:I
.field private fallbackX:I
.field private handler:Landroid/os/Handler;
.field private holdDir:I
.field private holdTicks:I
.field private inWebPlayer:Z
.field private isHoldingSeek:Z
.field private isPaused:Z
.field private lastControlActiveMs:J
.field private lastPlayPauseMs:J
.field private lastScanCurSec:I
.field private lastScanMs:J
.field private lastSeekMs:J
.field private needFreshScan:Z
.field private pendingAction:I
.field private pendingDeltaSec:I
.field private scanRetries:I
.field private targetSec:I
.field private thumbX:I
.field private totSec:I
.field private trackLeft:I
.field private trackRight:I

.method public constructor <init>()V
    .locals 1

    invoke-direct {p0}, Landroid/accessibilityservice/AccessibilityService;-><init>()V

    const/4 v0, -0x1
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->curSec:I
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastScanCurSec:I
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->totSec:I
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->targetSec:I
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->thumbX:I

    const/16 v0, 0x120
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->trackLeft:I
    const/16 v0, 0x624
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->trackRight:I
    const/16 v0, 0x12c
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->fallbackX:I

    return-void
.end method

.method private resetPlayerState()V
    .locals 2

    const/4 v0, 0x0
    iput-boolean v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->isPaused:Z
    iput-boolean v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->isHoldingSeek:Z
    iput-boolean v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->needFreshScan:Z
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->pendingAction:I
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->pendingDeltaSec:I
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->holdTicks:I
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->scanRetries:I

    const/4 v0, -0x1
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->curSec:I
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastScanCurSec:I
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->targetSec:I
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->thumbX:I

    const-wide/16 v0, 0x0
    iput-wide v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastControlActiveMs:J
    iput-wide v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastScanMs:J
    iput-wide v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastSeekMs:J

    iget-object v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->handler:Landroid/os/Handler;
    if-eqz v0, :cond_done
    invoke-virtual {v0, p0}, Landroid/os/Handler;->removeCallbacks(Ljava/lang/Runnable;)V

    :cond_done
    return-void
.end method

.method public onServiceConnected()V
    .locals 2

    invoke-super {p0}, Landroid/accessibilityservice/AccessibilityService;->onServiceConnected()V

    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;
    move-result-object v0
    new-instance v1, Landroid/os/Handler;
    invoke-direct {v1, v0}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V
    iput-object v1, p0, Lcom/mohit/pikaremote/PikaRemoteService;->handler:Landroid/os/Handler;

    invoke-virtual {p0}, Landroid/accessibilityservice/AccessibilityService;->getServiceInfo()Landroid/accessibilityservice/AccessibilityServiceInfo;
    move-result-object v0
    if-eqz v0, :cond_done

    iget v1, v0, Landroid/accessibilityservice/AccessibilityServiceInfo;->flags:I
    or-int/lit8 v1, v1, 0x73
    iput v1, v0, Landroid/accessibilityservice/AccessibilityServiceInfo;->flags:I
    invoke-virtual {p0, v0}, Landroid/accessibilityservice/AccessibilityService;->setServiceInfo(Landroid/accessibilityservice/AccessibilityServiceInfo;)V

    :cond_done
    return-void
.end method

.method public onAccessibilityEvent(Landroid/view/accessibility/AccessibilityEvent;)V
    .locals 2

    if-nez p1, :cond_check
    return-void

    :cond_check
    invoke-virtual {p1}, Landroid/view/accessibility/AccessibilityEvent;->getEventType()I
    move-result v0
    const/16 v1, 0x20
    if-ne v0, v1, :cond_done

    invoke-virtual {p1}, Landroid/view/accessibility/AccessibilityEvent;->getClassName()Ljava/lang/CharSequence;
    move-result-object v0
    if-eqz v0, :cond_done
    invoke-interface {v0}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;
    move-result-object v0
    const-string v1, "com.app.bluesun.view."
    invoke-virtual {v0, v1}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v0
    if-eqz v0, :cond_done

    invoke-direct {p0}, Lcom/mohit/pikaremote/PikaRemoteService;->resetPlayerState()V

    :cond_done
    return-void
.end method

.method public onInterrupt()V
    .locals 0
    return-void
.end method

.method private tap(II)V
    .locals 7

    new-instance v1, Landroid/graphics/Path;
    invoke-direct {v1}, Landroid/graphics/Path;-><init>()V

    int-to-float v2, p1
    int-to-float v3, p2
    invoke-virtual {v1, v2, v3}, Landroid/graphics/Path;->moveTo(FF)V

    new-instance v0, Landroid/accessibilityservice/GestureDescription$StrokeDescription;
    const-wide/16 v2, 0x0
    const-wide/16 v4, 0x3c
    invoke-direct/range {v0 .. v5}, Landroid/accessibilityservice/GestureDescription$StrokeDescription;-><init>(Landroid/graphics/Path;JJ)V

    new-instance v6, Landroid/accessibilityservice/GestureDescription$Builder;
    invoke-direct {v6}, Landroid/accessibilityservice/GestureDescription$Builder;-><init>()V
    invoke-virtual {v6, v0}, Landroid/accessibilityservice/GestureDescription$Builder;->addStroke(Landroid/accessibilityservice/GestureDescription$StrokeDescription;)Landroid/accessibilityservice/GestureDescription$Builder;
    invoke-virtual {v6}, Landroid/accessibilityservice/GestureDescription$Builder;->build()Landroid/accessibilityservice/GestureDescription;
    move-result-object v6

    const/4 v2, 0x0
    invoke-virtual {p0, v6, v2, v2}, Landroid/accessibilityservice/AccessibilityService;->dispatchGesture(Landroid/accessibilityservice/GestureDescription;Landroid/accessibilityservice/AccessibilityService$GestureResultCallback;Landroid/os/Handler;)Z

    return-void
.end method

.method private scheduleClearSelection()V
    .locals 4

    const/4 v0, 0x3
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->pendingAction:I

    iget-object v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->handler:Landroid/os/Handler;
    if-eqz v0, :cond_done

    invoke-virtual {v0, p0}, Landroid/os/Handler;->removeCallbacks(Ljava/lang/Runnable;)V
    const-wide/16 v1, 0x4b0
    invoke-virtual {v0, p0, v1, v2}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z

    :cond_done
    return-void
.end method

.method private performPlayPause(J)V
    .locals 6

    const/4 v0, 0x0
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->pendingAction:I
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->pendingDeltaSec:I
    iput-boolean v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->needFreshScan:Z
    iget-object v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->handler:Landroid/os/Handler;
    if-eqz v0, :cond_after_cancel
    invoke-virtual {v0, p0}, Landroid/os/Handler;->removeCallbacks(Ljava/lang/Runnable;)V

    :cond_after_cancel
    iget-boolean v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->isPaused:Z
    if-eqz v0, :cond_currently_playing

    const/4 v0, 0x0
    iput-boolean v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->isPaused:Z
    const-wide/16 v0, 0x0
    iput-wide v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastControlActiveMs:J
    iput-wide p1, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastScanMs:J

    const/16 v0, 0x3c2
    const/16 v1, 0x21c
    invoke-direct {p0, v0, v1}, Lcom/mohit/pikaremote/PikaRemoteService;->tap(II)V
    return-void

    :cond_currently_playing
    invoke-direct {p0}, Lcom/mohit/pikaremote/PikaRemoteService;->initTargetFromScan()V
    const/4 v0, 0x1
    iput-boolean v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->isPaused:Z

    iget-wide v2, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastControlActiveMs:J
    sub-long v2, p1, v2
    iput-wide p1, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastControlActiveMs:J

    const-wide/16 v4, 0xce4
    cmp-long v2, v2, v4
    if-gez v2, :cond_hidden_pause

    const/16 v0, 0x3c
    const/16 v1, 0x402
    invoke-direct {p0, v0, v1}, Lcom/mohit/pikaremote/PikaRemoteService;->tap(II)V
    return-void

    :cond_hidden_pause
    const/16 v0, 0x3c2
    const/16 v1, 0x21c
    invoke-direct {p0, v0, v1}, Lcom/mohit/pikaremote/PikaRemoteService;->tap(II)V

    const/4 v0, 0x1
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->pendingAction:I
    iget-object v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->handler:Landroid/os/Handler;
    if-eqz v0, :cond_done
    const-wide/16 v2, 0x154
    invoke-virtual {v0, p0, v2, v3}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z

    :cond_done
    return-void
.end method

.method private hasWebView(Landroid/view/accessibility/AccessibilityNodeInfo;)Z
    .locals 4

    const/4 v0, 0x0
    if-nez p1, :cond_check
    return v0

    :cond_check
    invoke-virtual {p1}, Landroid/view/accessibility/AccessibilityNodeInfo;->getClassName()Ljava/lang/CharSequence;
    move-result-object v1
    if-eqz v1, :cond_children

    invoke-interface {v1}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;
    move-result-object v1
    const-string v2, "android.webkit.WebView"
    invoke-virtual {v2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v1
    if-eqz v1, :cond_children
    const/4 v0, 0x1
    return v0

    :cond_children
    invoke-virtual {p1}, Landroid/view/accessibility/AccessibilityNodeInfo;->getChildCount()I
    move-result v1
    const/4 v2, 0x0

    :loop_start
    if-ge v2, v1, :loop_end
    invoke-virtual {p1, v2}, Landroid/view/accessibility/AccessibilityNodeInfo;->getChild(I)Landroid/view/accessibility/AccessibilityNodeInfo;
    move-result-object v3
    invoke-direct {p0, v3}, Lcom/mohit/pikaremote/PikaRemoteService;->hasWebView(Landroid/view/accessibility/AccessibilityNodeInfo;)Z
    move-result v3
    if-eqz v3, :next_child
    const/4 v0, 0x1
    return v0

    :next_child
    add-int/lit8 v2, v2, 0x1
    goto :loop_start

    :loop_end
    return v0
.end method

.method private isPikaWebPlayer()Z
    .locals 3

    const/4 v0, 0x0
    invoke-virtual {p0}, Landroid/accessibilityservice/AccessibilityService;->getRootInActiveWindow()Landroid/view/accessibility/AccessibilityNodeInfo;
    move-result-object v1
    if-nez v1, :cond_pkg
    return v0

    :cond_pkg
    invoke-virtual {v1}, Landroid/view/accessibility/AccessibilityNodeInfo;->getPackageName()Ljava/lang/CharSequence;
    move-result-object v2
    if-nez v2, :cond_check_pkg
    return v0

    :cond_check_pkg
    invoke-interface {v2}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;
    move-result-object v2
    const-string v0, "com.app.bluesun"
    invoke-virtual {v0, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-nez v0, :cond_find_cursor
    const/4 v0, 0x0
    return v0

    :cond_find_cursor
    const-string v0, "com.app.bluesun:id/cursorLayout"
    invoke-virtual {v1, v0}, Landroid/view/accessibility/AccessibilityNodeInfo;->findAccessibilityNodeInfosByViewId(Ljava/lang/String;)Ljava/util/List;
    move-result-object v0
    if-eqz v0, :cond_fallback_webview
    invoke-interface {v0}, Ljava/util/List;->isEmpty()Z
    move-result v0
    if-nez v0, :cond_fallback_webview
    const/4 v0, 0x1
    return v0

    :cond_fallback_webview
    invoke-direct {p0, v1}, Lcom/mohit/pikaremote/PikaRemoteService;->hasWebView(Landroid/view/accessibility/AccessibilityNodeInfo;)Z
    move-result v0
    return v0
.end method

.method private parseTimeSeconds(Ljava/lang/String;)I
    .locals 5

    :try_start
    invoke-virtual {p1}, Ljava/lang/String;->trim()Ljava/lang/String;
    move-result-object v0
    const-string v1, ":"
    invoke-virtual {v0, v1}, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;
    move-result-object v0
    array-length v1, v0

    const/4 v2, 0x2
    if-ne v1, v2, :cond_three

    const/4 v2, 0x0
    aget-object v2, v0, v2
    invoke-virtual {v2}, Ljava/lang/String;->trim()Ljava/lang/String;
    move-result-object v2
    invoke-static {v2}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I
    move-result v2
    mul-int/lit8 v2, v2, 0x3c

    const/4 v3, 0x1
    aget-object v3, v0, v3
    invoke-virtual {v3}, Ljava/lang/String;->trim()Ljava/lang/String;
    move-result-object v3
    invoke-static {v3}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I
    move-result v3

    add-int/2addr v2, v3
    return v2

    :cond_three
    const/4 v2, 0x3
    if-ne v1, v2, :cond_invalid

    const/4 v2, 0x0
    aget-object v2, v0, v2
    invoke-virtual {v2}, Ljava/lang/String;->trim()Ljava/lang/String;
    move-result-object v2
    invoke-static {v2}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I
    move-result v2
    const/16 v4, 0xe10
    mul-int/2addr v2, v4

    const/4 v3, 0x1
    aget-object v3, v0, v3
    invoke-virtual {v3}, Ljava/lang/String;->trim()Ljava/lang/String;
    move-result-object v3
    invoke-static {v3}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I
    move-result v3
    mul-int/lit8 v3, v3, 0x3c
    add-int/2addr v2, v3

    const/4 v3, 0x2
    aget-object v3, v0, v3
    invoke-virtual {v3}, Ljava/lang/String;->trim()Ljava/lang/String;
    move-result-object v3
    invoke-static {v3}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I
    move-result v3
    add-int/2addr v2, v3
    return v2
    :try_end
    .catch Ljava/lang/Exception; {:try_start .. :try_end} :catch_err

    :cond_invalid
    :catch_err
    const/4 v0, -0x1
    return v0
.end method

.method private scanTree(Landroid/view/accessibility/AccessibilityNodeInfo;)V
    .locals 5

    if-nez p1, :cond_start
    return-void

    :cond_start
    new-instance v0, Landroid/graphics/Rect;
    invoke-direct {v0}, Landroid/graphics/Rect;-><init>()V
    invoke-virtual {p1, v0}, Landroid/view/accessibility/AccessibilityNodeInfo;->getBoundsInScreen(Landroid/graphics/Rect;)V

    iget v1, v0, Landroid/graphics/Rect;->left:I
    iget v2, v0, Landroid/graphics/Rect;->top:I

    invoke-virtual {p1}, Landroid/view/accessibility/AccessibilityNodeInfo;->getText()Ljava/lang/CharSequence;
    move-result-object v3
    if-eqz v3, :cond_bounds

    const/16 v4, 0x3dc
    if-lt v2, v4, :cond_bounds
    const/16 v4, 0x118
    if-gt v1, v4, :cond_bounds

    invoke-interface {v3}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;
    move-result-object v3
    invoke-virtual {v3}, Ljava/lang/String;->trim()Ljava/lang/String;
    move-result-object v3

    const-string v4, ":"
    invoke-virtual {v3, v4}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v4
    if-eqz v4, :cond_bounds

    const-string v4, "/"
    invoke-virtual {v3, v4}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v4
    if-eqz v4, :cond_cur_time

    const/4 v4, 0x1
    invoke-virtual {v3, v4}, Ljava/lang/String;->substring(I)Ljava/lang/String;
    move-result-object v3
    invoke-direct {p0, v3}, Lcom/mohit/pikaremote/PikaRemoteService;->parseTimeSeconds(Ljava/lang/String;)I
    move-result v3
    if-lez v3, :cond_bounds
    iput v3, p0, Lcom/mohit/pikaremote/PikaRemoteService;->totSec:I
    goto :cond_bounds

    :cond_cur_time
    const/16 v4, 0xbe
    if-gt v1, v4, :cond_bounds
    invoke-direct {p0, v3}, Lcom/mohit/pikaremote/PikaRemoteService;->parseTimeSeconds(Ljava/lang/String;)I
    move-result v3
    if-ltz v3, :cond_bounds
    iput v3, p0, Lcom/mohit/pikaremote/PikaRemoteService;->curSec:I

    :cond_bounds
    const/16 v3, 0x402
    if-ne v2, v3, :cond_check_track
    iget v3, v0, Landroid/graphics/Rect;->bottom:I
    const/16 v4, 0x402
    if-ne v3, v4, :cond_check_track
    iget v3, v0, Landroid/graphics/Rect;->right:I
    if-ne v1, v3, :cond_check_track
    const/16 v3, 0x110
    if-lt v1, v3, :cond_check_track
    const/16 v3, 0x690
    if-gt v1, v3, :cond_check_track
    iput v1, p0, Lcom/mohit/pikaremote/PikaRemoteService;->thumbX:I
    goto :cond_children

    :cond_check_track
    const/16 v3, 0x3f2
    if-lt v2, v3, :cond_children
    const/16 v3, 0x3fe
    if-gt v2, v3, :cond_children

    iget v2, v0, Landroid/graphics/Rect;->bottom:I
    const/16 v3, 0x404
    if-lt v2, v3, :cond_children
    const/16 v3, 0x414
    if-gt v2, v3, :cond_children

    const/16 v2, 0xf0
    if-lt v1, v2, :cond_children
    const/16 v2, 0x190
    if-gt v1, v2, :cond_children

    iget v2, v0, Landroid/graphics/Rect;->right:I
    const/16 v3, 0x5dc
    if-lt v2, v3, :cond_check_fill
    const/16 v3, 0x690
    if-gt v2, v3, :cond_check_fill
    iput v1, p0, Lcom/mohit/pikaremote/PikaRemoteService;->trackLeft:I
    iput v2, p0, Lcom/mohit/pikaremote/PikaRemoteService;->trackRight:I
    goto :cond_children

    :cond_check_fill
    iget v3, p0, Lcom/mohit/pikaremote/PikaRemoteService;->trackLeft:I
    if-ne v1, v3, :cond_children
    if-lt v2, v1, :cond_children
    iget v3, p0, Lcom/mohit/pikaremote/PikaRemoteService;->trackRight:I
    if-ge v2, v3, :cond_children
    iput v2, p0, Lcom/mohit/pikaremote/PikaRemoteService;->fallbackX:I

    :cond_children
    invoke-virtual {p1}, Landroid/view/accessibility/AccessibilityNodeInfo;->getChildCount()I
    move-result v1
    const/4 v2, 0x0

    :loop_children
    if-ge v2, v1, :done_scan
    invoke-virtual {p1, v2}, Landroid/view/accessibility/AccessibilityNodeInfo;->getChild(I)Landroid/view/accessibility/AccessibilityNodeInfo;
    move-result-object v3
    invoke-direct {p0, v3}, Lcom/mohit/pikaremote/PikaRemoteService;->scanTree(Landroid/view/accessibility/AccessibilityNodeInfo;)V
    add-int/lit8 v2, v2, 0x1
    goto :loop_children

    :done_scan
    return-void
.end method

.method private applyDeltaToTarget(I)V
    .locals 4

    iget v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->totSec:I
    if-lez v0, :cond_no_tot

    iget v1, p0, Lcom/mohit/pikaremote/PikaRemoteService;->targetSec:I
    add-int/2addr v1, p1
    if-gez v1, :cond_clamp_top
    const/4 v1, 0x0

    :cond_clamp_top
    if-le v1, v0, :cond_save_target
    move v1, v0

    :cond_save_target
    iput v1, p0, Lcom/mohit/pikaremote/PikaRemoteService;->targetSec:I
    return-void

    :cond_no_tot
    const/16 v1, 0xf
    if-gez p1, :cond_add_fb
    const/16 v1, -0xf

    :cond_add_fb
    iget v2, p0, Lcom/mohit/pikaremote/PikaRemoteService;->fallbackX:I
    add-int/2addr v2, v1
    iget v3, p0, Lcom/mohit/pikaremote/PikaRemoteService;->trackLeft:I
    if-ge v2, v3, :cond_fb_top
    move v2, v3

    :cond_fb_top
    iget v3, p0, Lcom/mohit/pikaremote/PikaRemoteService;->trackRight:I
    if-le v2, v3, :cond_fb_save
    move v2, v3

    :cond_fb_save
    iput v2, p0, Lcom/mohit/pikaremote/PikaRemoteService;->fallbackX:I
    return-void
.end method

.method private initTargetFromScan()V
    .locals 6

    const/4 v0, -0x1
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->curSec:I
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->thumbX:I
    invoke-virtual {p0}, Landroid/accessibilityservice/AccessibilityService;->getRootInActiveWindow()Landroid/view/accessibility/AccessibilityNodeInfo;
    move-result-object v0
    invoke-direct {p0, v0}, Lcom/mohit/pikaremote/PikaRemoteService;->scanTree(Landroid/view/accessibility/AccessibilityNodeInfo;)V

    iget v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->thumbX:I
    if-lez v0, :cond_no_thumb
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->fallbackX:I

    :cond_no_thumb
    invoke-static {}, Landroid/os/SystemClock;->uptimeMillis()J
    move-result-wide v2

    iget v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->curSec:I
    if-ltz v0, :cond_try_target

    iget v1, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastScanCurSec:I
    if-ne v0, v1, :cond_fresh_scan

    iget-boolean v1, p0, Lcom/mohit/pikaremote/PikaRemoteService;->isPaused:Z
    if-nez v1, :cond_fresh_scan

    iget-wide v4, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastScanMs:J
    cmp-long v1, v4, v2
    if-gtz v1, :cond_fresh_scan

    sub-long v4, v2, v4
    const-wide/16 v0, 0x3e8
    div-long/2addr v4, v0
    long-to-int v1, v4

    const/4 v4, 0x2
    if-lt v1, v4, :cond_fresh_scan
    const/16 v4, 0x1c20
    if-gt v1, v4, :cond_fresh_scan

    iget v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->targetSec:I
    if-gez v0, :cond_add_elapsed
    iget v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->curSec:I

    :cond_add_elapsed
    add-int/2addr v0, v1
    iget v1, p0, Lcom/mohit/pikaremote/PikaRemoteService;->totSec:I
    if-lez v1, :cond_save_est
    if-le v0, v1, :cond_save_est
    move v0, v1

    :cond_save_est
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->targetSec:I
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastScanCurSec:I
    iput-wide v2, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastScanMs:J
    return-void

    :cond_fresh_scan
    iget v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->curSec:I
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->targetSec:I
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastScanCurSec:I
    iput-wide v2, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastScanMs:J
    return-void

    :cond_try_target
    iget v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->targetSec:I
    if-ltz v0, :cond_try_px

    iget-boolean v1, p0, Lcom/mohit/pikaremote/PikaRemoteService;->isPaused:Z
    if-nez v1, :cond_keep_target
    iget-wide v4, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastScanMs:J
    const-wide/16 v0, 0x0
    cmp-long v0, v4, v0
    if-lez v0, :cond_keep_target
    sub-long v4, v2, v4
    const-wide/16 v0, 0x3e8
    div-long/2addr v4, v0
    long-to-int v1, v4
    if-lez v1, :cond_keep_target
    const/16 v4, 0x1c20
    if-gt v1, v4, :cond_keep_target
    iget v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->targetSec:I
    add-int/2addr v0, v1
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->targetSec:I
    iput-wide v2, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastScanMs:J

    :cond_keep_target
    return-void

    :cond_try_px
    iget v1, p0, Lcom/mohit/pikaremote/PikaRemoteService;->totSec:I
    if-lez v1, :cond_zero_base
    iget v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->fallbackX:I
    iget v4, p0, Lcom/mohit/pikaremote/PikaRemoteService;->trackLeft:I
    iget v5, p0, Lcom/mohit/pikaremote/PikaRemoteService;->trackRight:I
    sub-int/2addr v5, v4
    if-lez v5, :cond_zero_base
    sub-int/2addr v0, v4
    mul-int/2addr v0, v1
    div-int/2addr v0, v5
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->targetSec:I
    iput-wide v2, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastScanMs:J
    return-void

    :cond_zero_base
    const/4 v0, 0x0
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->targetSec:I
    iput-wide v2, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastScanMs:J
    return-void
.end method

.method private tapSeekBarAtTarget(J)V
    .locals 7

    iput-wide p1, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastScanMs:J
    iget v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->trackLeft:I
    iget v1, p0, Lcom/mohit/pikaremote/PikaRemoteService;->trackRight:I
    sub-int v2, v1, v0
    if-gtz v2, :cond_width_ok
    const/16 v2, 0x540

    :cond_width_ok
    iget v3, p0, Lcom/mohit/pikaremote/PikaRemoteService;->totSec:I
    iget v4, p0, Lcom/mohit/pikaremote/PikaRemoteService;->targetSec:I
    if-lez v3, :cond_fallback
    if-ltz v4, :cond_fallback

    mul-int v5, v4, v2
    div-int/2addr v5, v3
    add-int/2addr v5, v0
    iput v5, p0, Lcom/mohit/pikaremote/PikaRemoteService;->fallbackX:I

    new-instance v0, Ljava/lang/StringBuilder;
    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V
    const-string v2, "seek cur="
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    iget v2, p0, Lcom/mohit/pikaremote/PikaRemoteService;->curSec:I
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    const-string v2, " target="
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0, v4}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    const-string v2, " tot="
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    const-string v2, " ["
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    iget v2, p0, Lcom/mohit/pikaremote/PikaRemoteService;->trackLeft:I
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    const-string v2, ".."
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    const-string v2, "] x="
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    invoke-virtual {v0, v5}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    const-string v2, " th="
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    iget v2, p0, Lcom/mohit/pikaremote/PikaRemoteService;->thumbX:I
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    const-string v2, " r="
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
    iget v2, p0, Lcom/mohit/pikaremote/PikaRemoteService;->scanRetries:I
    invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;
    move-result-object v0
    const-string v2, "PikaRemote"
    invoke-static {v2, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    const/16 v6, 0x401
    invoke-direct {p0, v5, v6}, Lcom/mohit/pikaremote/PikaRemoteService;->tap(II)V
    return-void

    :cond_fallback
    iget v5, p0, Lcom/mohit/pikaremote/PikaRemoteService;->fallbackX:I
    const/16 v6, 0x401
    invoke-direct {p0, v5, v6}, Lcom/mohit/pikaremote/PikaRemoteService;->tap(II)V
    return-void
.end method

.method private scheduleHoldTick(J)V
    .locals 2

    const/4 v0, 0x4
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->pendingAction:I

    iget-object v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->handler:Landroid/os/Handler;
    if-eqz v0, :cond_done
    invoke-virtual {v0, p0}, Landroid/os/Handler;->removeCallbacks(Ljava/lang/Runnable;)V
    invoke-virtual {v0, p0, p1, p2}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z

    :cond_done
    return-void
.end method

.method private onSeekKeyDown(IJ)V
    .locals 6

    const/4 v0, 0x1
    iput-boolean v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->isHoldingSeek:Z
    iput p1, p0, Lcom/mohit/pikaremote/PikaRemoteService;->holdDir:I
    const/4 v0, 0x0
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->holdTicks:I

    iget v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->pendingAction:I
    const/4 v1, 0x3
    if-eq v0, v1, :cond_cancel_timer
    const/4 v1, 0x4
    if-ne v0, v1, :cond_check_waking

    :cond_cancel_timer
    const/4 v0, 0x0
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->pendingAction:I
    iget-object v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->handler:Landroid/os/Handler;
    if-eqz v0, :cond_check_waking
    invoke-virtual {v0, p0}, Landroid/os/Handler;->removeCallbacks(Ljava/lang/Runnable;)V

    :cond_check_waking
    iget-boolean v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->needFreshScan:Z
    if-eqz v0, :cond_not_waking

    iget v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->pendingDeltaSec:I
    add-int/2addr v0, p1
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->pendingDeltaSec:I
    iput-wide p2, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastSeekMs:J
    return-void

    :cond_not_waking
    iget-boolean v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->isPaused:Z
    if-nez v0, :cond_controls_already_awake

    iget-wide v2, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastControlActiveMs:J
    sub-long v2, p2, v2
    const-wide/16 v4, 0xce4
    cmp-long v2, v2, v4
    if-gez v2, :cond_wake_first
    goto :cond_controls_already_awake

    :cond_wake_first
    const/4 v0, 0x1
    iput-boolean v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->needFreshScan:Z
    const/4 v0, 0x0
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->scanRetries:I
    iput p1, p0, Lcom/mohit/pikaremote/PikaRemoteService;->pendingDeltaSec:I
    iput-wide p2, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastControlActiveMs:J
    iput-wide p2, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastSeekMs:J

    const/16 v0, 0x3c2
    const/16 v1, 0x21c
    invoke-direct {p0, v0, v1}, Lcom/mohit/pikaremote/PikaRemoteService;->tap(II)V

    const/4 v0, 0x2
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->pendingAction:I
    iget-object v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->handler:Landroid/os/Handler;
    if-eqz v0, :cond_wake_done
    invoke-virtual {v0, p0}, Landroid/os/Handler;->removeCallbacks(Ljava/lang/Runnable;)V
    const-wide/16 v2, 0x154
    invoke-virtual {v0, p0, v2, v3}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z

    :cond_wake_done
    return-void

    :cond_controls_already_awake
    iget v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->targetSec:I
    if-ltz v0, :cond_do_fresh_scan

    iget-wide v2, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastSeekMs:J
    sub-long v2, p2, v2
    const-wide/16 v4, 0xdac
    cmp-long v2, v2, v4
    if-gez v2, :cond_do_fresh_scan
    goto :cond_have_session

    :cond_do_fresh_scan
    invoke-direct {p0}, Lcom/mohit/pikaremote/PikaRemoteService;->initTargetFromScan()V

    :cond_have_session
    iput-wide p2, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastSeekMs:J
    iput-wide p2, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastControlActiveMs:J
    invoke-direct {p0, p1}, Lcom/mohit/pikaremote/PikaRemoteService;->applyDeltaToTarget(I)V
    invoke-direct {p0, p2, p3}, Lcom/mohit/pikaremote/PikaRemoteService;->tapSeekBarAtTarget(J)V

    const-wide/16 v2, 0x208
    invoke-direct {p0, v2, v3}, Lcom/mohit/pikaremote/PikaRemoteService;->scheduleHoldTick(J)V
    return-void
.end method

.method private onSeekKeyUp(J)V
    .locals 2

    const/4 v0, 0x0
    iput-boolean v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->isHoldingSeek:Z

    iget-boolean v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->needFreshScan:Z
    if-eqz v0, :cond_check_hold_timer
    return-void

    :cond_check_hold_timer
    iget v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->pendingAction:I
    const/4 v1, 0x4
    if-ne v0, v1, :cond_done

    invoke-direct {p0}, Lcom/mohit/pikaremote/PikaRemoteService;->scheduleClearSelection()V

    :cond_done
    return-void
.end method

.method public run()V
    .locals 4

    iget v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->pendingAction:I
    const/4 v1, 0x0
    iput v1, p0, Lcom/mohit/pikaremote/PikaRemoteService;->pendingAction:I

    const/4 v1, 0x1
    if-ne v0, v1, :cond_check_pending_seek

    const/16 v1, 0x3c
    const/16 v2, 0x402
    invoke-direct {p0, v1, v2}, Lcom/mohit/pikaremote/PikaRemoteService;->tap(II)V
    return-void

    :cond_check_pending_seek
    const/4 v1, 0x2
    if-ne v0, v1, :cond_check_clear

    iget-boolean v1, p0, Lcom/mohit/pikaremote/PikaRemoteService;->needFreshScan:Z
    if-eqz v1, :cond_tap_seek_now

    invoke-direct {p0}, Lcom/mohit/pikaremote/PikaRemoteService;->initTargetFromScan()V
    iget v1, p0, Lcom/mohit/pikaremote/PikaRemoteService;->curSec:I
    if-gez v1, :cond_scan_ready

    iget v1, p0, Lcom/mohit/pikaremote/PikaRemoteService;->scanRetries:I
    const/4 v2, 0x3
    if-ge v1, v2, :cond_scan_ready

    add-int/lit8 v1, v1, 0x1
    iput v1, p0, Lcom/mohit/pikaremote/PikaRemoteService;->scanRetries:I
    const/4 v1, 0x2
    iput v1, p0, Lcom/mohit/pikaremote/PikaRemoteService;->pendingAction:I
    iget-object v1, p0, Lcom/mohit/pikaremote/PikaRemoteService;->handler:Landroid/os/Handler;
    if-eqz v1, :cond_done
    const-wide/16 v2, 0x96
    invoke-virtual {v1, p0, v2, v3}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z
    return-void

    :cond_scan_ready
    const/4 v1, 0x0
    iput-boolean v1, p0, Lcom/mohit/pikaremote/PikaRemoteService;->needFreshScan:Z
    iput v1, p0, Lcom/mohit/pikaremote/PikaRemoteService;->scanRetries:I
    iget v1, p0, Lcom/mohit/pikaremote/PikaRemoteService;->pendingDeltaSec:I
    const/4 v2, 0x0
    iput v2, p0, Lcom/mohit/pikaremote/PikaRemoteService;->pendingDeltaSec:I
    invoke-direct {p0, v1}, Lcom/mohit/pikaremote/PikaRemoteService;->applyDeltaToTarget(I)V

    :cond_tap_seek_now
    invoke-static {}, Landroid/os/SystemClock;->uptimeMillis()J
    move-result-wide v2
    iput-wide v2, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastControlActiveMs:J
    iput-wide v2, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastSeekMs:J
    invoke-direct {p0, v2, v3}, Lcom/mohit/pikaremote/PikaRemoteService;->tapSeekBarAtTarget(J)V

    iget-boolean v1, p0, Lcom/mohit/pikaremote/PikaRemoteService;->isHoldingSeek:Z
    if-eqz v1, :cond_not_holding_after_wake

    const-wide/16 v2, 0x17c
    invoke-direct {p0, v2, v3}, Lcom/mohit/pikaremote/PikaRemoteService;->scheduleHoldTick(J)V
    return-void

    :cond_not_holding_after_wake
    invoke-direct {p0}, Lcom/mohit/pikaremote/PikaRemoteService;->scheduleClearSelection()V
    return-void

    :cond_check_clear
    const/4 v1, 0x3
    if-ne v0, v1, :cond_check_hold_tick

    iget-boolean v1, p0, Lcom/mohit/pikaremote/PikaRemoteService;->isPaused:Z
    if-nez v1, :cond_done

    invoke-static {}, Landroid/os/SystemClock;->uptimeMillis()J
    move-result-wide v2
    iput-wide v2, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastControlActiveMs:J

    const/16 v1, 0x3c2
    const/16 v2, 0x12c
    invoke-direct {p0, v1, v2}, Lcom/mohit/pikaremote/PikaRemoteService;->tap(II)V
    return-void

    :cond_check_hold_tick
    const/4 v1, 0x4
    if-ne v0, v1, :cond_done

    iget-boolean v1, p0, Lcom/mohit/pikaremote/PikaRemoteService;->isHoldingSeek:Z
    if-eqz v1, :cond_done

    iget v1, p0, Lcom/mohit/pikaremote/PikaRemoteService;->holdTicks:I
    add-int/lit8 v1, v1, 0x1
    iput v1, p0, Lcom/mohit/pikaremote/PikaRemoteService;->holdTicks:I

    iget v2, p0, Lcom/mohit/pikaremote/PikaRemoteService;->holdDir:I
    const/4 v3, 0x4
    if-le v1, v3, :cond_step_2x
    const/16 v3, 0xa
    if-le v1, v3, :cond_step_3x

    mul-int/lit8 v2, v2, 0x6
    goto :cond_apply_hold

    :cond_step_3x
    mul-int/lit8 v2, v2, 0x3
    goto :cond_apply_hold

    :cond_step_2x
    mul-int/lit8 v2, v2, 0x2

    :cond_apply_hold
    invoke-static {}, Landroid/os/SystemClock;->uptimeMillis()J
    move-result-wide v0
    iput-wide v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastControlActiveMs:J
    iput-wide v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastSeekMs:J
    invoke-direct {p0, v2}, Lcom/mohit/pikaremote/PikaRemoteService;->applyDeltaToTarget(I)V
    invoke-direct {p0, v0, v1}, Lcom/mohit/pikaremote/PikaRemoteService;->tapSeekBarAtTarget(J)V

    const-wide/16 v0, 0xfa
    invoke-direct {p0, v0, v1}, Lcom/mohit/pikaremote/PikaRemoteService;->scheduleHoldTick(J)V

    :cond_done
    return-void
.end method

.method public onKeyEvent(Landroid/view/KeyEvent;)Z
    .locals 10

    invoke-virtual {p1}, Landroid/view/KeyEvent;->getKeyCode()I
    move-result v0
    invoke-virtual {p1}, Landroid/view/KeyEvent;->getAction()I
    move-result v1
    invoke-virtual {p1}, Landroid/view/KeyEvent;->getRepeatCount()I
    move-result v2

    const/4 v3, 0x4
    if-ne v0, v3, :cond_check_keys
    if-nez v1, :cond_back_pass
    invoke-direct {p0}, Lcom/mohit/pikaremote/PikaRemoteService;->resetPlayerState()V
    :cond_back_pass
    const/4 v0, 0x0
    return v0

    :cond_check_keys
    const/16 v3, 0x17
    if-eq v0, v3, :cond_relevant
    const/16 v3, 0x42
    if-eq v0, v3, :cond_relevant
    const/16 v3, 0x55
    if-eq v0, v3, :cond_relevant
    const/16 v3, 0x7e
    if-eq v0, v3, :cond_relevant
    const/16 v3, 0x7f
    if-eq v0, v3, :cond_relevant
    const/16 v3, 0x15
    if-eq v0, v3, :cond_relevant
    const/16 v3, 0x16
    if-eq v0, v3, :cond_relevant
    const/16 v3, 0x59
    if-eq v0, v3, :cond_relevant
    const/16 v3, 0x5a
    if-eq v0, v3, :cond_relevant

    const/4 v0, 0x0
    return v0

    :cond_relevant
    if-nez v1, :cond_use_cached_web
    if-nez v2, :cond_use_cached_web

    invoke-direct {p0}, Lcom/mohit/pikaremote/PikaRemoteService;->isPikaWebPlayer()Z
    move-result v3
    iput-boolean v3, p0, Lcom/mohit/pikaremote/PikaRemoteService;->inWebPlayer:Z
    if-nez v3, :cond_in_web

    invoke-direct {p0}, Lcom/mohit/pikaremote/PikaRemoteService;->resetPlayerState()V
    const/4 v0, 0x0
    return v0

    :cond_use_cached_web
    iget-boolean v3, p0, Lcom/mohit/pikaremote/PikaRemoteService;->inWebPlayer:Z
    if-nez v3, :cond_in_web
    const/4 v0, 0x0
    return v0

    :cond_in_web
    const/4 v3, 0x1
    const/16 v4, 0x17
    if-eq v0, v4, :cond_play_pause
    const/16 v4, 0x42
    if-eq v0, v4, :cond_play_pause
    const/16 v4, 0x55
    if-eq v0, v4, :cond_play_pause
    const/16 v4, 0x7e
    if-eq v0, v4, :cond_play_pause
    const/16 v4, 0x7f
    if-ne v0, v4, :cond_seek

    :cond_play_pause
    if-nez v1, :cond_swallow_pp
    if-nez v2, :cond_swallow_pp

    invoke-static {}, Landroid/os/SystemClock;->uptimeMillis()J
    move-result-wide v4
    iget-wide v6, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastPlayPauseMs:J
    sub-long v6, v4, v6
    const-wide/16 v8, 0x15e
    cmp-long v6, v6, v8
    if-ltz v6, :cond_swallow_pp

    iput-wide v4, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastPlayPauseMs:J
    invoke-direct {p0, v4, v5}, Lcom/mohit/pikaremote/PikaRemoteService;->performPlayPause(J)V

    :cond_swallow_pp
    return v3

    :cond_seek
    invoke-static {}, Landroid/os/SystemClock;->uptimeMillis()J
    move-result-wide v4

    if-eqz v1, :cond_seek_down
    invoke-direct {p0, v4, v5}, Lcom/mohit/pikaremote/PikaRemoteService;->onSeekKeyUp(J)V
    return v3

    :cond_seek_down
    if-nez v2, :cond_swallow_repeat
    iget-boolean v6, p0, Lcom/mohit/pikaremote/PikaRemoteService;->isHoldingSeek:Z
    if-nez v6, :cond_swallow_repeat

    const/16 v1, 0xa
    const/16 v6, 0x15
    if-eq v0, v6, :cond_neg
    const/16 v6, 0x59
    if-ne v0, v6, :cond_pos

    :cond_neg
    const/16 v1, -0xa

    :cond_pos
    invoke-direct {p0, v1, v4, v5}, Lcom/mohit/pikaremote/PikaRemoteService;->onSeekKeyDown(IJ)V

    :cond_swallow_repeat
    return v3
.end method
EOF

echo "==> Building APK with apktool ..."
"$APKTOOL" b "$WORK_DIR/src" -o "$WORK_DIR/PikaRemoteHelper-unsigned.apk"

echo "==> Signing APK with persistent key ..."
mkdir -p "$HOME/.android"
KEYSTORE="$HOME/.android/pika-debug.keystore"
if [ ! -f "$KEYSTORE" ]; then
  keytool -genkeypair -v \
    -keystore "$KEYSTORE" \
    -storepass android \
    -keypass android \
    -alias androiddebugkey \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -dname "CN=Android Debug,O=Android,C=US" >/dev/null 2>&1
fi

cp "$WORK_DIR/PikaRemoteHelper-unsigned.apk" "$WORK_DIR/PikaRemoteHelper.apk"
jarsigner -sigalg SHA256withRSA -digestalg SHA-256 \
  -keystore "$KEYSTORE" \
  -storepass android \
  -keypass android \
  "$WORK_DIR/PikaRemoteHelper.apk" androiddebugkey >/dev/null

echo "==> Installing PikaRemoteHelper.apk on Mi TV Box ..."
"$ADB" connect 192.168.1.128:5555 || true
"$ADB" install -r "$WORK_DIR/PikaRemoteHelper.apk" || (
  "$ADB" uninstall com.mohit.pikaremote >/dev/null 2>&1 || true
  "$ADB" install -r "$WORK_DIR/PikaRemoteHelper.apk"
)

echo "==> Rebinding PikaRemoteService in Android Accessibility Settings ..."
SVC="com.mohit.pikaremote/com.mohit.pikaremote.PikaRemoteService"
"$ADB" shell settings put secure enabled_accessibility_services '""'
"$ADB" shell settings put secure accessibility_enabled 0
sleep 1
"$ADB" shell settings put secure enabled_accessibility_services "$SVC"
"$ADB" shell settings put secure accessibility_enabled 1

echo ""
echo "=========================================================="
echo " DONE! PikaRemoteHelper is installed and active on the TV!"
echo " - Single-click OK/Center : Play / Pause"
echo " - Single-click Right     : Skip Forward +10s"
echo " - Single-click Left      : Skip Backward -10s"
echo " - Back / Home / Menus    : Work 100% normally"
echo "=========================================================="

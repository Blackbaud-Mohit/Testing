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
    android:accessibilityEventTypes="typeWindowStateChanged|typeWindowContentChanged"
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

.field private controlsVisible:Z
.field private curSec:I
.field private fallbackX:I
.field private handler:Landroid/os/Handler;
.field private isPaused:Z
.field private lastControlActiveMs:J
.field private lastSeekMs:J
.field private lastSeenCurSec:I
.field private pendingAction:I
.field private pendingDeltaSec:I
.field private targetSec:I
.field private totSec:I
.field private trackLeft:I
.field private trackRight:I

.method public constructor <init>()V
    .locals 1

    invoke-direct {p0}, Landroid/accessibilityservice/AccessibilityService;-><init>()V

    const/4 v0, -0x1
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->curSec:I
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastSeenCurSec:I
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->totSec:I
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->targetSec:I

    const/16 v0, 0x120
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->trackLeft:I
    const/16 v0, 0x660
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->trackRight:I
    const/16 v0, 0x12c
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->fallbackX:I

    return-void
.end method

.method public onServiceConnected()V
    .locals 2

    invoke-super {p0}, Landroid/accessibilityservice/AccessibilityService;->onServiceConnected()V

    const-string v0, "PikaRemote"
    const-string v1, "service connected"
    invoke-static {v0, v1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

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
    .locals 0
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
    const-wide/16 v4, 0x19
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

.method private performPlayPause()V
    .locals 6

    const/4 v0, -0x1
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->curSec:I

    invoke-virtual {p0}, Landroid/accessibilityservice/AccessibilityService;->getRootInActiveWindow()Landroid/view/accessibility/AccessibilityNodeInfo;
    move-result-object v0
    invoke-direct {p0, v0}, Lcom/mohit/pikaremote/PikaRemoteService;->scanTree(Landroid/view/accessibility/AccessibilityNodeInfo;)V

    const/4 v0, 0x0
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->pendingAction:I
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->pendingDeltaSec:I
    iget-object v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->handler:Landroid/os/Handler;
    if-eqz v0, :cond_after_cancel
    invoke-virtual {v0, p0}, Landroid/os/Handler;->removeCallbacks(Ljava/lang/Runnable;)V

    :cond_after_cancel
    iget v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->curSec:I
    if-ltz v0, :cond_check_paused
    iget v1, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastSeenCurSec:I
    if-ltz v1, :cond_save_seen
    sub-int v2, v0, v1
    const/4 v3, 0x5
    if-ge v2, v3, :cond_playing_tick
    if-gez v2, :cond_check_paused

    :cond_playing_tick
    const/4 v2, 0x0
    iput-boolean v2, p0, Lcom/mohit/pikaremote/PikaRemoteService;->isPaused:Z

    :cond_save_seen
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastSeenCurSec:I

    :cond_check_paused
    iget-boolean v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->isPaused:Z
    if-eqz v0, :cond_currently_playing

    const/4 v0, 0x0
    iput-boolean v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->isPaused:Z
    const-wide/16 v0, 0x0
    iput-wide v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastControlActiveMs:J

    const/16 v0, 0x3c2
    const/16 v1, 0x21c
    invoke-direct {p0, v0, v1}, Lcom/mohit/pikaremote/PikaRemoteService;->tap(II)V
    return-void

    :cond_currently_playing
    const/4 v0, 0x1
    iput-boolean v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->isPaused:Z

    invoke-static {}, Landroid/os/SystemClock;->uptimeMillis()J
    move-result-wide v0
    iget-wide v2, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastSeekMs:J
    sub-long v2, v0, v2
    iput-wide v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastControlActiveMs:J

    const-wide/16 v4, 0xfa0
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
    const-wide/16 v2, 0xa0
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
    invoke-virtual {p1}, Landroid/view/accessibility/AccessibilityNodeInfo;->getText()Ljava/lang/CharSequence;
    move-result-object v0
    if-eqz v0, :cond_bounds

    invoke-interface {v0}, Ljava/lang/CharSequence;->toString()Ljava/lang/String;
    move-result-object v0
    invoke-virtual {v0}, Ljava/lang/String;->trim()Ljava/lang/String;
    move-result-object v0

    const-string v1, ":"
    invoke-virtual {v0, v1}, Ljava/lang/String;->contains(Ljava/lang/CharSequence;)Z
    move-result v1
    if-eqz v1, :cond_bounds

    const-string v1, "/"
    invoke-virtual {v0, v1}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z
    move-result v1
    if-eqz v1, :cond_cur_time

    const/4 v1, 0x1
    invoke-virtual {v0, v1}, Ljava/lang/String;->substring(I)Ljava/lang/String;
    move-result-object v0
    invoke-direct {p0, v0}, Lcom/mohit/pikaremote/PikaRemoteService;->parseTimeSeconds(Ljava/lang/String;)I
    move-result v1
    if-lez v1, :cond_bounds
    iput v1, p0, Lcom/mohit/pikaremote/PikaRemoteService;->totSec:I
    goto :cond_bounds

    :cond_cur_time
    invoke-direct {p0, v0}, Lcom/mohit/pikaremote/PikaRemoteService;->parseTimeSeconds(Ljava/lang/String;)I
    move-result v1
    if-ltz v1, :cond_bounds
    iput v1, p0, Lcom/mohit/pikaremote/PikaRemoteService;->curSec:I

    :cond_bounds
    new-instance v0, Landroid/graphics/Rect;
    invoke-direct {v0}, Landroid/graphics/Rect;-><init>()V
    invoke-virtual {p1, v0}, Landroid/view/accessibility/AccessibilityNodeInfo;->getBoundsInScreen(Landroid/graphics/Rect;)V

    iget v1, v0, Landroid/graphics/Rect;->left:I
    const/16 v2, 0x37a
    if-ne v1, v2, :cond_check_track
    iget v2, v0, Landroid/graphics/Rect;->top:I
    const/16 v3, 0x1d6
    if-ne v2, v3, :cond_check_track
    const/4 v2, 0x1
    iput-boolean v2, p0, Lcom/mohit/pikaremote/PikaRemoteService;->controlsVisible:Z

    :cond_check_track
    iget v2, v0, Landroid/graphics/Rect;->top:I
    const/16 v3, 0x3fe
    if-ne v2, v3, :cond_children

    iget v2, v0, Landroid/graphics/Rect;->bottom:I
    const/16 v3, 0x404
    if-ne v2, v3, :cond_children

    const/16 v2, 0xf0
    if-lt v1, v2, :cond_children
    const/16 v2, 0x190
    if-gt v1, v2, :cond_children

    iget v2, v0, Landroid/graphics/Rect;->right:I
    const/16 v3, 0x660
    if-ne v2, v3, :cond_check_fill
    iput v1, p0, Lcom/mohit/pikaremote/PikaRemoteService;->trackLeft:I
    iput v2, p0, Lcom/mohit/pikaremote/PikaRemoteService;->trackRight:I
    goto :cond_children

    :cond_check_fill
    if-lt v2, v1, :cond_children
    if-ge v2, v3, :cond_children
    iput v1, p0, Lcom/mohit/pikaremote/PikaRemoteService;->trackLeft:I
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

.method private performSeek(I)V
    .locals 10

    const/4 v0, -0x1
    iput v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->curSec:I
    const/4 v0, 0x0
    iput-boolean v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->controlsVisible:Z

    invoke-virtual {p0}, Landroid/accessibilityservice/AccessibilityService;->getRootInActiveWindow()Landroid/view/accessibility/AccessibilityNodeInfo;
    move-result-object v0
    invoke-direct {p0, v0}, Lcom/mohit/pikaremote/PikaRemoteService;->scanTree(Landroid/view/accessibility/AccessibilityNodeInfo;)V

    invoke-static {}, Landroid/os/SystemClock;->uptimeMillis()J
    move-result-wide v0
    iput-wide v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastControlActiveMs:J

    iget v6, p0, Lcom/mohit/pikaremote/PikaRemoteService;->trackLeft:I
    iget v7, p0, Lcom/mohit/pikaremote/PikaRemoteService;->trackRight:I
    sub-int v7, v7, v6
    if-gtz v7, :cond_width_ok
    const/16 v7, 0x540

    :cond_width_ok
    iget v2, p0, Lcom/mohit/pikaremote/PikaRemoteService;->totSec:I
    if-lez v2, :cond_fallback

    iget v3, p0, Lcom/mohit/pikaremote/PikaRemoteService;->targetSec:I
    if-ltz v3, :cond_use_cur
    iget-wide v4, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastSeekMs:J
    sub-long v4, v0, v4
    const-wide/16 v8, 0xfa0
    cmp-long v4, v4, v8
    if-gez v4, :cond_use_cur
    goto :cond_have_base

    :cond_use_cur
    iget v3, p0, Lcom/mohit/pikaremote/PikaRemoteService;->curSec:I
    if-ltz v3, :cond_use_px
    iput v3, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastSeenCurSec:I
    goto :cond_have_base

    :cond_use_px
    iget v3, p0, Lcom/mohit/pikaremote/PikaRemoteService;->fallbackX:I
    iget v6, p0, Lcom/mohit/pikaremote/PikaRemoteService;->trackLeft:I
    sub-int/2addr v3, v6
    mul-int/2addr v3, v2
    div-int/2addr v3, v7

    :cond_have_base
    add-int/2addr v3, p1
    if-gez v3, :cond_check_max
    const/4 v3, 0x0

    :cond_check_max
    if-le v3, v2, :cond_save_target
    move v3, v2

    :cond_save_target
    iput v3, p0, Lcom/mohit/pikaremote/PikaRemoteService;->targetSec:I
    iput-wide v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastSeekMs:J

    iget v6, p0, Lcom/mohit/pikaremote/PikaRemoteService;->trackLeft:I
    iget v7, p0, Lcom/mohit/pikaremote/PikaRemoteService;->trackRight:I
    sub-int/2addr v7, v6
    mul-int/2addr v3, v7
    div-int/2addr v3, v2
    add-int/2addr v3, v6

    const/16 v4, 0x403
    invoke-direct {p0, v3, v4}, Lcom/mohit/pikaremote/PikaRemoteService;->tap(II)V
    invoke-direct {p0}, Lcom/mohit/pikaremote/PikaRemoteService;->scheduleClearSelection()V
    return-void

    :cond_fallback
    const/16 v3, 0xf
    if-gez p1, :cond_step_ready
    const/16 v3, -0xf

    :cond_step_ready
    iget v4, p0, Lcom/mohit/pikaremote/PikaRemoteService;->fallbackX:I
    add-int/2addr v4, v3
    iget v5, p0, Lcom/mohit/pikaremote/PikaRemoteService;->trackLeft:I
    if-ge v4, v5, :cond_fb_max
    move v4, v5

    :cond_fb_max
    iget v5, p0, Lcom/mohit/pikaremote/PikaRemoteService;->trackRight:I
    if-le v4, v5, :cond_fb_tap
    move v4, v5

    :cond_fb_tap
    iput v4, p0, Lcom/mohit/pikaremote/PikaRemoteService;->fallbackX:I
    const/16 v5, 0x403
    invoke-direct {p0, v4, v5}, Lcom/mohit/pikaremote/PikaRemoteService;->tap(II)V
    invoke-direct {p0}, Lcom/mohit/pikaremote/PikaRemoteService;->scheduleClearSelection()V
    return-void
.end method

.method public run()V
    .locals 3

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

    iget v1, p0, Lcom/mohit/pikaremote/PikaRemoteService;->pendingDeltaSec:I
    const/4 v2, 0x0
    iput v2, p0, Lcom/mohit/pikaremote/PikaRemoteService;->pendingDeltaSec:I
    invoke-direct {p0, v1}, Lcom/mohit/pikaremote/PikaRemoteService;->performSeek(I)V
    return-void

    :cond_check_clear
    const/4 v1, 0x3
    if-ne v0, v1, :cond_done

    iget-boolean v1, p0, Lcom/mohit/pikaremote/PikaRemoteService;->isPaused:Z
    if-nez v1, :cond_done

    const/16 v1, 0x3c2
    const/16 v2, 0x12c
    invoke-direct {p0, v1, v2}, Lcom/mohit/pikaremote/PikaRemoteService;->tap(II)V

    :cond_done
    return-void
.end method

.method public onKeyEvent(Landroid/view/KeyEvent;)Z
    .locals 8

    invoke-virtual {p1}, Landroid/view/KeyEvent;->getKeyCode()I
    move-result v0

    const-string v1, "PikaRemote"
    invoke-static {v0}, Ljava/lang/String;->valueOf(I)Ljava/lang/String;
    move-result-object v2
    invoke-static {v1, v2}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    const/16 v1, 0x17
    if-eq v0, v1, :cond_relevant
    const/16 v1, 0x42
    if-eq v0, v1, :cond_relevant
    const/16 v1, 0x55
    if-eq v0, v1, :cond_relevant
    const/16 v1, 0x15
    if-eq v0, v1, :cond_relevant
    const/16 v1, 0x16
    if-eq v0, v1, :cond_relevant
    const/16 v1, 0x59
    if-eq v0, v1, :cond_relevant
    const/16 v1, 0x5a
    if-eq v0, v1, :cond_relevant

    const/4 v0, 0x0
    return v0

    :cond_relevant
    invoke-direct {p0}, Lcom/mohit/pikaremote/PikaRemoteService;->isPikaWebPlayer()Z
    move-result v1
    if-nez v1, :cond_in_web
    const/4 v0, 0x0
    iput-boolean v0, p0, Lcom/mohit/pikaremote/PikaRemoteService;->isPaused:Z
    const/4 v1, -0x1
    iput v1, p0, Lcom/mohit/pikaremote/PikaRemoteService;->targetSec:I
    iput v1, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastSeenCurSec:I
    return v0

    :cond_in_web
    invoke-virtual {p1}, Landroid/view/KeyEvent;->getAction()I
    move-result v1
    const/4 v2, 0x1
    if-eqz v1, :cond_down
    return v2

    :cond_down
    const/16 v1, 0x17
    if-eq v0, v1, :cond_play_pause
    const/16 v1, 0x42
    if-eq v0, v1, :cond_play_pause
    const/16 v1, 0x55
    if-ne v0, v1, :cond_seek

    :cond_play_pause
    invoke-direct {p0}, Lcom/mohit/pikaremote/PikaRemoteService;->performPlayPause()V
    return v2

    :cond_seek
    const/16 v1, 0xa
    const/16 v3, 0x15
    if-eq v0, v3, :cond_neg
    const/16 v3, 0x59
    if-ne v0, v3, :cond_pos

    :cond_neg
    const/16 v1, -0xa

    :cond_pos
    iget v3, p0, Lcom/mohit/pikaremote/PikaRemoteService;->pendingAction:I
    const/4 v4, 0x2
    if-ne v3, v4, :cond_check_awake

    iget v3, p0, Lcom/mohit/pikaremote/PikaRemoteService;->pendingDeltaSec:I
    add-int/2addr v3, v1
    iput v3, p0, Lcom/mohit/pikaremote/PikaRemoteService;->pendingDeltaSec:I
    return v2

    :cond_check_awake
    invoke-static {}, Landroid/os/SystemClock;->uptimeMillis()J
    move-result-wide v3
    iget-wide v5, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastControlActiveMs:J
    sub-long v5, v3, v5
    iput-wide v3, p0, Lcom/mohit/pikaremote/PikaRemoteService;->lastControlActiveMs:J

    iget-boolean v3, p0, Lcom/mohit/pikaremote/PikaRemoteService;->isPaused:Z
    if-nez v3, :cond_seek_awake
    const-wide/16 v3, 0x1388
    cmp-long v3, v5, v3
    if-gez v3, :cond_seek_wake_first

    :cond_seek_awake
    invoke-direct {p0, v1}, Lcom/mohit/pikaremote/PikaRemoteService;->performSeek(I)V
    return v2

    :cond_seek_wake_first
    const/4 v3, 0x2
    iput v3, p0, Lcom/mohit/pikaremote/PikaRemoteService;->pendingAction:I
    iput v1, p0, Lcom/mohit/pikaremote/PikaRemoteService;->pendingDeltaSec:I

    const/16 v3, 0x3c2
    const/16 v4, 0x21c
    invoke-direct {p0, v3, v4}, Lcom/mohit/pikaremote/PikaRemoteService;->tap(II)V

    iget-object v3, p0, Lcom/mohit/pikaremote/PikaRemoteService;->handler:Landroid/os/Handler;
    if-eqz v3, :cond_seek_done
    invoke-virtual {v3, p0}, Landroid/os/Handler;->removeCallbacks(Ljava/lang/Runnable;)V
    const-wide/16 v4, 0xc8
    invoke-virtual {v3, p0, v4, v5}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z

    :cond_seek_done
    return v2
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

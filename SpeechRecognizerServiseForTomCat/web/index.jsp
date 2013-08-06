<%-- 
    Document   : index
    Created on : Aug 2, 2013, 8:13:52 PM
    Author     : Studentas
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Speech Recognition</title>
    </head>
    <body>
        <h3>To start working with this project you will need to make these steps:<br>
-Download and install NetBeans 7.3.1 or higher with Apache Tomcat server bundle. You can download it here:<br>
https://netbeans.org/downloads/<br>
-Download and install Adobe Flash (you can use Adobe Flash Professional CC, which can be downloaded <br>
here https://creative.adobe.com/products/flash)<br>
-Download SpeechRecognition project from https://github.com/adform/SpeechRecognition<br>
-Extract zip file you downloaded, open SpeechRecognizerServiseForTomCat project with NetBeans. <br>
To test web service on NetBeans, right click on SpeechRecognizerServiseForTomCat project, select <br>
Deploy, wait till it is done, expand SpeechRecognizerServiseForTomCat project, expand Web Services <br>
folder, right click on Sphinx4Service, select Test Web Service.<br>
-To upload service in Tomcat server you will need to build project to get war file. Right click on <br>
project, select Clean and Build, wait till it is done. SpeechRecognizerServiseForTomCat.war will be <br>
generated in SpeechRecognizerServiseForTomCat\dist\ folder. To upload it, go to <br>
http://fe531b79fb5842daacdcfbaa0c39104a.cloudapp.net/ click on Manager App, log in, scroll down to <br>
"WAR file to deploy" part, choose generated war file and click Deploy. It might take some time to upload it.<br>
-Open recording.fla with Adobe Flash to test the banner. Go to Control, then Test Movies and choose<br>
to test in Flash or in Browser.<br>
(note: when you try to test banner localy you need to have file recording.swf<br>
added us trusted file, that you can do in Global Security Settings panel which can be found here: <br>
http://www.macromedia.com/support/documentation/en/flashplayer/help/settings_manager04.html).<br>
Banner's class is in file Main.as, here you can edit banner's behaviour.<br>
If you want to make new swf file, go to File, then Export and click on Export movie.<h3>
    </body>
</html>

package 
{
	import flash.display.Sprite;
	import flash.media.Microphone;
	import flash.system.Security;
	import org.bytearray.micrecorder.*;
	import org.bytearray.micrecorder.events.RecordingEvent;
	import org.bytearray.micrecorder.encoder.WaveEncoder;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.events.ActivityEvent;
	import fl.transitions.Tween;
	import fl.transitions.easing.Strong;
	import flash.net.FileReference;
	import mx.rpc.soap.*;
	import mx.rpc.events.*;
	import mx.rpc.AbstractOperation;

	public class Main extends Sprite
	{
		private var mic:Microphone;
		private var waveEncoder:WaveEncoder = new WaveEncoder();
		private var recorder:MicRecorder = new MicRecorder(waveEncoder);
		private var recBar:RecBar = new RecBar();
		private var tween:Tween;
		private var fileReference:FileReference = new FileReference();
		public var responseAPI2:ResponseAPI = new ResponseAPI();
		private var ws:WebService;
		var uNameWebService:WebService;
		var serviceOperation:AbstractOperation;

		public function Main():void
		{
			recButton.stop();
			stButton.stop();
			mic = Microphone.getMicrophone();
			mic.setSilenceLevel(0);
			mic.gain = 100;
			Security.showSettings("2");
			InitWebService();
			addListeners();
		}

		private function addListeners():void
		{
			recButton.addEventListener(MouseEvent.MOUSE_UP, startRecording);
			recorder.addEventListener(RecordingEvent.RECORDING, recording);
			recorder.addEventListener(Event.COMPLETE, recordComplete);
		}

		private function startRecording(e:MouseEvent):void
		{
			if (mic != null)
			{
				recorder.record();
				e.target.gotoAndStop(2);

				recButton.removeEventListener(MouseEvent.MOUSE_UP, startRecording);
				stButton.addEventListener(MouseEvent.MOUSE_UP, stopRecording);

				addChild(recBar);

				tween = new Tween(recBar,"y",Strong.easeOut, -  recBar.height,0,1,true);
			}
		}

		private function stopRecording(e:MouseEvent):void
		{
			recorder.stop();

			mic.setLoopBack(false);
			e.target.gotoAndStop(1);

			stButton.removeEventListener(MouseEvent.MOUSE_UP, stopRecording);
			recButton.addEventListener(MouseEvent.MOUSE_UP, startRecording);

			tween = new Tween(recBar,"y",Strong.easeOut,0, -  recBar.height,1,true);
		}

		private function recording(e:RecordingEvent):void
		{
			var currentTime:int = Math.floor(e.time / 1000);

			recBar.counter.text = String(currentTime);

			if (String(currentTime).length == 1)
			{
				recBar.counter.text = "00:0" + currentTime;
			}
			else if (String(currentTime).length == 2)
			{
				recBar.counter.text = "00:" + currentTime;
			}
		}

		private function recordComplete(e:Event):void
		{
			fileReference.save(recorder.output, "recording.wav");
		}
		function InitWebService():void
		{
			uNameWebService = new WebService();
			uNameWebService.loadWSDL("http://api.adform.com/Services/SecurityService.svc/wsdl");
			uNameWebService.addEventListener(LoadEvent.LOAD, BuildServiceRequest);
		}
		function BuildServiceRequest(evt:LoadEvent)
		{
			serviceOperation = uNameWebService.getOperation("Login");
			serviceOperation.addEventListener(FaultEvent.FAULT, DisplayError);
			serviceOperation.addEventListener(ResultEvent.RESULT, DisplayResult);
			var params:Object = new Object();
			params.UserName='optimizing';
			params.Password='OptimizingAds#1';
			serviceOperation.send(params);
		}
		function DisplayError(evt:FaultEvent)
		{
			responseAPI2.ticket.text = evt.fault.faultString;
		    addChild(responseAPI2);
			trace("error");
		}
		function DisplayResult(evt:ResultEvent)
		{

			var Result:String = evt.result as String;
			responseAPI2.ticket.text = Result;
			addChild(responseAPI2);
		}

	}
}
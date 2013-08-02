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
	import flash.events.StatusEvent;
	import fl.transitions.Tween;
	import fl.transitions.easing.Strong;
	import flash.net.FileReference;
	import mx.rpc.soap.*;
	import mx.rpc.events.*;
	import mx.rpc.AbstractOperation;


	public class Main extends Sprite
	{
		private var mic:Microphone;
		private var waveEncoder:WaveEncoder = new WaveEncoder  ;
		private var recorder:MicRecorder = new MicRecorder(waveEncoder);
		private var recBar:RecBar = new RecBar  ;
		private var tween:Tween;
		public var responseAPI2:ResponseAPI = new ResponseAPI  ;
		var uNameWebService:WebService;
		var serviceOperation:AbstractOperation;
		public var activity:int = new int  ;
		public var entered:Boolean = new Boolean  ;



		public function Main():void
		{

			mic = Microphone.getMicrophone();
			mic.setSilenceLevel(0);
			mic.gain = 60;
			mic.setUseEchoSuppression(true);
			mic.rate = 16;
			entered = true;
			activity = 10;
			addListeners();

		}

		private function addListeners():void
		{
			recorder.addEventListener(RecordingEvent.RECORDING,recording);
			recorder.addEventListener(Event.COMPLETE,InitWebService);
			responseAPI2.addEventListener(Event.ENTER_FRAME,activeSound);
			startRecording();
		}
		private function startRecording():void
		{
			if ((mic != null))
			{
				recorder.record();
				addChild(recBar);
				tween = new Tween(recBar,"y",Strong.easeOut, -  recBar.height,0,1,true);
			}
		}
		private function activeSound(e:Event):void
		{
			if (mic.activityLevel > activity + 10)
			{
				activity = mic.activityLevel;
				entered = false;
			}
			if (mic.activityLevel < 8 && entered == false)
			{
				entered = true;
				stopRecording();
			}
		}
		private function stopRecording():void
		{
			recorder.stop();
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

		function InitWebService(e:Event):void
		{
			addChild(responseAPI2);
			uNameWebService = new WebService  ;
			uNameWebService.loadWSDL("http://localhost:8080/SpeechRecognizerService/Sphinx4Service?WSDL");
			uNameWebService.addEventListener(LoadEvent.LOAD,BuildServiceRequest);
		}
		function BuildServiceRequest(e:LoadEvent)
		{
			serviceOperation = uNameWebService.getOperation("GetStringFromAudio");
			serviceOperation.addEventListener(FaultEvent.FAULT,DisplayError);
			serviceOperation.addEventListener(ResultEvent.RESULT,DisplayResult);
			serviceOperation.send(recorder.output);
		}

		function DisplayError(e:FaultEvent)
		{
			responseAPI2.ticket.text = e.fault.faultString;
			addChild(responseAPI2);
			trace("error");
		}
		function DisplayResult(e:ResultEvent)
		{

			var Result:String = e.result as String;
			if ((Result != null))
			{
				responseAPI2.ticket.text = Result;
				entered = true;
				activity = 10;
				startRecording();
			}
			else
			{
				responseAPI2.ticket.text = "null";
			}
			addChild(responseAPI2);
		}

	}
}
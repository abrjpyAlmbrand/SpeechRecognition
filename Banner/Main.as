package 
{
	import flash.display.Sprite;
	import flash.media.Microphone;
	import flash.system.Security;
	import flash.utils.*;
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
			}
		}
		private function activeSound(e:Event):void
		{
			if (mic.activityLevel > activity + 10)
			{
				activity = mic.activityLevel;
				entered = false;
			}
			if (mic.activityLevel < 20 && entered == false)
			{
				entered = true;
				var intervalId:uint = setTimeout(stopRecording, 700);
			}
		}
		private function stopRecording():void
		{
			recorder.stop();
			rec.txt.text = "...";
			addChild(rec);


		}

		private function recording(e:RecordingEvent):void
		{
			rec.txt.text = "Recording...";
			addChild(rec);
		}

		function InitWebService(e:Event):void
		{
			addChild(responseAPI2);
			uNameWebService = new WebService  ;
			uNameWebService.loadWSDL("http://fe531b79fb5842daacdcfbaa0c39104a.cloudapp.net/SpeechRecognizerServiseForTomCat/Sphinx4Service?wsdl");
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
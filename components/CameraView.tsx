import React, { useEffect, useRef } from 'react';

interface CameraViewProps {
  isTrackingActive: boolean;
  onRallyEndDetected: () => void;
}

const CameraView: React.FC<CameraViewProps> = ({ isTrackingActive, onRallyEndDetected }) => {
  const videoRef = useRef<HTMLVideoElement>(null);
  const intervalRef = useRef<number | null>(null);

  useEffect(() => {
    let stream: MediaStream | null = null;
    const setupCamera = async () => {
      try {
        stream = await navigator.mediaDevices.getUserMedia({ video: true });
        if (videoRef.current) {
          videoRef.current.srcObject = stream;
        }
      } catch (err) {
        console.error("Error accessing camera: ", err);
        alert("Could not access the camera. Please ensure permissions are granted and try again.");
      }
    };
    setupCamera();

    return () => {
      if (stream) {
        stream.getTracks().forEach(track => track.stop());
      }
    };
  }, []);

  useEffect(() => {
    if (isTrackingActive) {
      // Simulate rally detection every 5-8 seconds
      const randomInterval = Math.random() * 3000 + 5000;
      intervalRef.current = window.setInterval(() => {
        onRallyEndDetected();
      }, randomInterval);
    } else {
      if (intervalRef.current) {
        clearInterval(intervalRef.current);
        intervalRef.current = null;
      }
    }

    return () => {
      if (intervalRef.current) {
        clearInterval(intervalRef.current);
      }
    };
  }, [isTrackingActive, onRallyEndDetected]);

  return (
    <div className="w-full max-w-lg mx-auto my-4 relative rounded-lg overflow-hidden border-2 border-gray-700 shadow-lg">
      <video ref={videoRef} autoPlay playsInline muted className="w-full h-auto block" />
      <div 
        className={`absolute inset-0 flex items-center justify-center text-white font-bold text-2xl uppercase tracking-widest transition-opacity ${isTrackingActive ? 'bg-black bg-opacity-30' : 'bg-black bg-opacity-60'}`}
      >
        <div 
            className={`px-4 py-2 rounded-lg ${isTrackingActive ? 'bg-green-600 bg-opacity-80' : 'bg-gray-600 bg-opacity-80'}`}
        >
            {isTrackingActive ? 'Tracking Active' : 'Tracking Paused'}
        </div>
      </div>
    </div>
  );
};

export default CameraView;
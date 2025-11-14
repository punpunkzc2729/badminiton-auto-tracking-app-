import React, { useState, useCallback, useMemo } from 'react';
import { Match, Game, Rally, Side, EndReason, AiSuggestion } from './types';
import { isGameOver, getGameWinner, isMatchOver, getMatchWinner } from './utils/scoring';
import { simulateRally } from './services/geminiService';
import Scoreboard from './components/Scoreboard';
import CameraView from './components/CameraView';
import { UndoIcon, RedoIcon, CheckIcon, XIcon, ShuttlecockIcon, InfoIcon } from './components/icons';

const initialState: Match | null = null;

// Helper to define components outside the main App component
const GameEndScreen: React.FC<{ winnerName: string; scoreA: number; scoreB: number; onNextGame: () => void; }> = ({ winnerName, scoreA, scoreB, onNextGame }) => (
  <div className="fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center z-50">
    <div className="bg-light-bg p-8 rounded-lg text-center shadow-2xl">
      <h2 className="text-3xl font-bold text-accent-yellow mb-2">Game Over!</h2>
      <p className="text-xl mb-4">{winnerName} wins the game!</p>
      <p className="text-4xl font-bold mb-6">{scoreA} - {scoreB}</p>
      <button onClick={onNextGame} className="bg-brand-blue hover:bg-brand-green text-white font-bold py-2 px-6 rounded-lg transition-colors">
        Start Next Game
      </button>
    </div>
  </div>
);

const MatchEndScreen: React.FC<{ winnerName: string; onNewMatch: () => void; }> = ({ winnerName, onNewMatch }) => (
  <div className="fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center z-50">
    <div className="bg-light-bg p-8 rounded-lg text-center shadow-2xl">
      <h2 className="text-3xl font-bold text-accent-yellow mb-2">Match Over!</h2>
      <p className="text-xl mb-6">{winnerName} wins the match!</p>
      <button onClick={onNewMatch} className="bg-brand-blue hover:bg-brand-green text-white font-bold py-2 px-6 rounded-lg transition-colors">
        Start New Match
      </button>
    </div>
  </div>
);

const AiSuggestionDisplay: React.FC<{ suggestion: AiSuggestion; onConfirm: () => void; onReject: () => void; playerA: string; playerB: string; }> = ({ suggestion, onConfirm, onReject, playerA, playerB }) => (
    <div className="bg-light-bg p-4 rounded-lg my-4 flex flex-col md:flex-row items-center justify-between gap-4 animate-fade-in shadow-lg border border-gray-700">
        <div className="flex-grow">
            <h3 className="text-lg font-semibold text-brand-green">AI Suggestion</h3>
            <p>
                Point to <span className="font-bold text-accent-yellow">{suggestion.winner_side === Side.A ? playerA : playerB}</span>.
                Reason: <span className="font-semibold">{suggestion.end_reason}</span>
            </p>
            {suggestion.playerTrackingNote && (
                <div className="mt-2 flex items-start gap-2 text-sm text-gray-300">
                    <InfoIcon className="w-5 h-5 text-brand-blue flex-shrink-0 mt-0.5" />
                    <p><span className="font-semibold">AI Insight:</span> {suggestion.playerTrackingNote}</p>
                </div>
            )}
        </div>
        <div className="flex items-center gap-2 flex-shrink-0">
            <button onClick={onConfirm} className="bg-green-600 hover:bg-green-500 rounded-full p-3 transition-colors"><CheckIcon /></button>
            <button onClick={onReject} className="bg-red-600 hover:red-500 rounded-full p-3 transition-colors"><XIcon /></button>
        </div>
    </div>
);

const ManualOverridePanel: React.FC<{ onSelect: (winner: Side, reason: EndReason) => void; onCancel: () => void; }> = ({ onSelect, onCancel }) => (
  <div className="bg-light-bg p-4 rounded-lg my-4 flex flex-col items-center gap-4 animate-fade-in">
    <h3 className="text-lg font-semibold text-red-500">Manual Override</h3>
    <div className="flex flex-wrap justify-center gap-2">
      <button onClick={() => onSelect(Side.A, EndReason.MANUAL)} className="bg-brand-blue hover:bg-brand-green text-white font-bold py-2 px-4 rounded">Point A</button>
      <button onClick={() => onSelect(Side.B, EndReason.MANUAL)} className="bg-brand-blue hover:bg-brand-green text-white font-bold py-2 px-4 rounded">Point B</button>
      <button onClick={() => onSelect(Side.A, EndReason.LET)} className="bg-gray-600 hover:bg-gray-500 text-white font-bold py-2 px-4 rounded">LET</button>
    </div>
    <button onClick={onCancel} className="text-sm text-gray-400 hover:text-white">Cancel</button>
  </div>
);

const MatchSetup: React.FC<{ onStartMatch: (playerA: string, playerB: string, bestOf: 3 | 5, useCamera: boolean) => void; }> = ({ onStartMatch }) => {
  const [playerA, setPlayerA] = useState('Player A');
  const [playerB, setPlayerB] = useState('Player B');
  const [bestOf, setBestOf] = useState<3 | 5>(3);
  const [useCamera, setUseCamera] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onStartMatch(playerA, playerB, bestOf, useCamera);
  };

  return (
    <div className="min-h-screen flex items-center justify-center p-4">
      <form onSubmit={handleSubmit} className="bg-light-bg p-8 rounded-lg shadow-2xl w-full max-w-md">
        <h1 className="text-3xl font-bold text-center mb-6 text-accent-yellow">New Badminton Match</h1>
        <div className="mb-4">
          <label className="block text-gray-300 mb-2" htmlFor="playerA">Player A</label>
          <input type="text" id="playerA" value={playerA} onChange={(e) => setPlayerA(e.target.value)} className="w-full bg-dark-bg p-2 rounded border border-gray-600 focus:outline-none focus:ring-2 focus:ring-brand-green" />
        </div>
        <div className="mb-4">
          <label className="block text-gray-300 mb-2" htmlFor="playerB">Player B</label>
          <input type="text" id="playerB" value={playerB} onChange={(e) => setPlayerB(e.target.value)} className="w-full bg-dark-bg p-2 rounded border border-gray-600 focus:outline-none focus:ring-2 focus:ring-brand-green" />
        </div>
        <div className="mb-4">
          <span className="block text-gray-300 mb-2">Best of</span>
          <div className="flex gap-4">
            <button type="button" onClick={() => setBestOf(3)} className={`flex-1 py-2 rounded ${bestOf === 3 ? 'bg-brand-blue' : 'bg-gray-700'}`}>3 Games</button>
            <button type="button" onClick={() => setBestOf(5)} className={`flex-1 py-2 rounded ${bestOf === 5 ? 'bg-brand-blue' : 'bg-gray-700'}`}>5 Games</button>
          </div>
        </div>
        <div className="mb-6">
          <label className="flex items-center gap-3 cursor-pointer">
            <input type="checkbox" checked={useCamera} onChange={(e) => setUseCamera(e.target.checked)} className="w-5 h-5 accent-brand-green" />
            <span className="text-gray-300">Enable Camera Tracking</span>
          </label>
        </div>
        <button type="submit" className="w-full bg-brand-green hover:bg-blue-400 text-white font-bold py-3 px-4 rounded transition-colors text-lg">
          Start Match
        </button>
      </form>
    </div>
  );
};


export default function App() {
  const [match, setMatch] = useState<Match | null>(initialState);
  const [history, setHistory] = useState<Match[]>([]);
  const [redoStack, setRedoStack] = useState<Match[]>([]);

  const [isLoadingAi, setIsLoadingAi] = useState(false);
  const [aiSuggestion, setAiSuggestion] = useState<AiSuggestion | null>(null);
  const [isManualOverride, setIsManualOverride] = useState(false);
  
  const [isCameraTrackingEnabled, setIsCameraTrackingEnabled] = useState(false);
  const [isTrackingActive, setIsTrackingActive] = useState(false);

  const currentGame = useMemo(() => match?.games[match.games.length - 1], [match]);

  const updateMatchState = useCallback((newMatchState: Match) => {
    if (match) {
      setHistory(prev => [...prev, match]);
    }
    setMatch(newMatchState);
    setRedoStack([]); // Clear redo stack on new action
  }, [match]);

  const handleStartMatch = useCallback((playerA: string, playerB: string, bestOf: 3 | 5, useCamera: boolean) => {
    const newMatch: Match = {
      matchId: `match-${Date.now()}`,
      playerA,
      playerB,
      bestOf,
      games: [{
        gameIndex: 1,
        scoreA: 0,
        scoreB: 0,
        rallies: [],
        winner: null,
        isComplete: false,
      }],
      winner: null,
      isComplete: false,
      server: Side.A,
    };
    setMatch(newMatch);
    setHistory([]);
    setRedoStack([]);
    setIsCameraTrackingEnabled(useCamera);
    setIsTrackingActive(false);
  }, []);
  
  const handleNextGame = useCallback(() => {
    if (!match || !currentGame) return;

    const newGame: Game = {
        gameIndex: currentGame.gameIndex + 1,
        scoreA: 0,
        scoreB: 0,
        rallies: [],
        winner: null,
        isComplete: false,
    };

    updateMatchState({
      ...match,
      games: [...match.games, newGame],
      server: match.server === Side.A ? Side.B : Side.A, // Alternate server start
    });

  }, [match, currentGame, updateMatchState]);

  const processRally = useCallback((winnerSide: Side, endReason: EndReason, isManual: boolean) => {
    if (!match || !currentGame || currentGame.isComplete) return;

    if (endReason === EndReason.LET) {
        // Handle LET: no score change, server remains the same.
        const newRally: Rally = { rallyId: `rally-${Date.now()}`, serverSide: match.server, winnerSide: null, endReason: EndReason.LET, isManualOverride: isManual };
        const updatedGame = { ...currentGame, rallies: [...currentGame.rallies, newRally] };
        const updatedGames = [...match.games.slice(0, -1), updatedGame];
        updateMatchState({ ...match, games: updatedGames });
        setAiSuggestion(null);
        setIsManualOverride(false);
        return;
    }

    let { scoreA, scoreB } = currentGame;
    if (winnerSide === Side.A) scoreA++;
    else scoreB++;

    const newRally: Rally = {
      rallyId: `rally-${Date.now()}`,
      serverSide: match.server,
      winnerSide: winnerSide,
      endReason: endReason,
      isManualOverride: isManual,
    };

    const gameIsOver = isGameOver(scoreA, scoreB);
    const gameWinner = gameIsOver ? getGameWinner(scoreA, scoreB) : null;
    
    const updatedGame = { ...currentGame, scoreA, scoreB, rallies: [...currentGame.rallies, newRally], isComplete: gameIsOver, winner: gameWinner };
    const updatedGames = [...match.games.slice(0, -1), updatedGame];

    const matchIsOver = isMatchOver(updatedGames, match.bestOf);
    const matchWinner = matchIsOver ? getMatchWinner(updatedGames, match.bestOf) : null;

    const newMatchState: Match = {
      ...match,
      games: updatedGames,
      server: winnerSide,
      isComplete: matchIsOver,
      winner: matchWinner
    };

    updateMatchState(newMatchState);
    setAiSuggestion(null);
    setIsManualOverride(false);
  }, [match, currentGame, updateMatchState]);

  const triggerAiSuggestion = async () => {
    if (!match) return;
    setIsLoadingAi(true);
    setAiSuggestion(null);
    setIsManualOverride(false);

    const suggestion = await simulateRally(match);
    if (suggestion) {
      setAiSuggestion(suggestion);
    }
    setIsLoadingAi(false);
  };
  
  const handleToggleTracking = () => {
    setIsTrackingActive(prev => !prev);
  }

  const handleUndo = useCallback(() => {
    if (history.length > 0) {
      const lastState = history[history.length - 1];
      const newHistory = history.slice(0, -1);
      setHistory(newHistory);
      if(match) setRedoStack(prev => [match, ...prev]);
      setMatch(lastState);
      setAiSuggestion(null);
      setIsManualOverride(false);
      setIsTrackingActive(false);
    }
  }, [history, match]);

  const handleRedo = useCallback(() => {
    if (redoStack.length > 0) {
      const nextState = redoStack[0];
      const newRedoStack = redoStack.slice(1);
      if(match) setHistory(prev => [...prev, match]);
      setRedoStack(newRedoStack);
      setMatch(nextState);
    }
  }, [redoStack, match]);

  if (!match) {
    return <MatchSetup onStartMatch={handleStartMatch} />;
  }
  
  if (match.isComplete) {
    return <MatchEndScreen winnerName={match.winner === Side.A ? match.playerA : match.playerB} onNewMatch={() => { setMatch(null); setIsCameraTrackingEnabled(false); }} />;
  }

  if (currentGame?.isComplete) {
    return <GameEndScreen winnerName={currentGame.winner === Side.A ? match.playerA : match.playerB} scoreA={currentGame.scoreA} scoreB={currentGame.scoreB} onNextGame={handleNextGame} />;
  }
  
  const canInteract = !isLoadingAi && !aiSuggestion && !isManualOverride;

  return (
    <div className="container mx-auto p-4 flex flex-col min-h-screen justify-between">
      <header className="text-center">
        <h1 className="text-2xl sm:text-3xl md:text-4xl font-bold tracking-tight text-white flex items-center justify-center gap-3">
            <ShuttlecockIcon className="w-8 h-8 text-brand-green"/> Badminton AI Scoring Engine
        </h1>
      </header>
      
      <main className="flex-grow flex flex-col items-center justify-center">
        <Scoreboard match={match} />
        
        {isCameraTrackingEnabled && (
          <CameraView 
            isTrackingActive={isTrackingActive}
            onRallyEndDetected={triggerAiSuggestion}
          />
        )}

        <div className="w-full max-w-lg mx-auto mt-4">
          {isLoadingAi && <div className="text-center p-4">Asking AI...</div>}
          {aiSuggestion && <AiSuggestionDisplay suggestion={aiSuggestion} onConfirm={() => processRally(aiSuggestion.winner_side, aiSuggestion.end_reason, false)} onReject={() => { setAiSuggestion(null); setIsManualOverride(true); }} playerA={match.playerA} playerB={match.playerB} />}
          {isManualOverride && <ManualOverridePanel onSelect={(winner, reason) => processRally(winner, reason, true)} onCancel={() => setIsManualOverride(false)}/>}
        </div>
      </main>

      <footer className="w-full max-w-lg mx-auto py-4">
        {canInteract && (
          isCameraTrackingEnabled ? (
            <button 
              onClick={handleToggleTracking} 
              className={`w-full font-bold text-xl py-4 rounded-lg shadow-lg hover:opacity-90 transition-opacity ${isTrackingActive ? 'bg-red-600 text-white' : 'bg-accent-yellow text-dark-bg'}`}
            >
              {isTrackingActive ? 'Stop Tracking' : 'Start Tracking'}
            </button>
          ) : (
            <button onClick={triggerAiSuggestion} className="w-full bg-accent-yellow text-dark-bg font-bold text-xl py-4 rounded-lg shadow-lg hover:opacity-90 transition-opacity">
              Start Rally
            </button>
          )
        )}
        <div className="flex items-center justify-center gap-4 mt-4">
          <button onClick={handleUndo} disabled={history.length === 0} className="flex items-center gap-2 p-2 rounded-lg bg-light-bg disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-600 transition-colors">
            <UndoIcon /> Undo
          </button>
          <button onClick={handleRedo} disabled={redoStack.length === 0} className="flex items-center gap-2 p-2 rounded-lg bg-light-bg disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-600 transition-colors">
            <RedoIcon /> Redo
          </button>
        </div>
      </footer>
    </div>
  );
}
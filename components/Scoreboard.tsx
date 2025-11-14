import React from 'react';
import { Match, Side, ServingCourt } from '../types';
import { getServingCourt } from '../utils/scoring';
import { ShuttlecockIcon } from './icons';

interface ScoreboardProps {
  match: Match;
}

const PlayerScore: React.FC<{
  name: string;
  score: number;
  gamesWon: number;
  isServing: boolean;
  servingCourt: ServingCourt;
  side: Side;
}> = ({ name, score, gamesWon, isServing, servingCourt, side }) => {
  const servingCourtIndicator = (
    <div className={`absolute top-2 ${side === Side.A ? 'right-2' : 'left-2'} flex items-center gap-2 text-accent-yellow`}>
      <div className={`w-8 h-8 rounded-full flex items-center justify-center font-bold text-lg ${servingCourt === ServingCourt.LEFT ? 'bg-brand-blue' : 'bg-transparent'}`}>
        L
      </div>
      <div className={`w-8 h-8 rounded-full flex items-center justify-center font-bold text-lg ${servingCourt === ServingCourt.RIGHT ? 'bg-brand-blue' : 'bg-transparent'}`}>
        R
      </div>
    </div>
  );

  return (
    <div className="flex-1 bg-light-bg rounded-lg p-4 sm:p-6 md:p-8 flex flex-col items-center justify-center relative text-center">
      {isServing && servingCourtIndicator}
      <h2 className="text-2xl sm:text-3xl md:text-4xl font-semibold truncate w-full max-w-[20ch]">{name}</h2>
      <div className="text-7xl sm:text-8xl md:text-9xl font-black my-4 text-accent-yellow">{score}</div>
      <div className="flex items-center gap-2 text-lg sm:text-xl text-gray-300">
        Games: {gamesWon}
        {isServing && <ShuttlecockIcon className="w-6 h-6 text-brand-green animate-pulse" />}
      </div>
    </div>
  );
};


const Scoreboard: React.FC<ScoreboardProps> = ({ match }) => {
  const currentGame = match.games[match.games.length - 1];
  const gamesWonA = match.games.filter(g => g.winner === Side.A).length;
  const gamesWonB = match.games.filter(g => g.winner === Side.B).length;

  const serverScore = match.server === Side.A ? currentGame.scoreA : currentGame.scoreB;
  const servingCourt = getServingCourt(serverScore);

  return (
    <div className="w-full max-w-5xl mx-auto p-4">
      <div className="flex items-stretch justify-center gap-2 sm:gap-4">
        <PlayerScore
          name={match.playerA}
          score={currentGame.scoreA}
          gamesWon={gamesWonA}
          isServing={match.server === Side.A}
          servingCourt={servingCourt}
          side={Side.A}
        />
        <div className="flex items-center justify-center text-4xl font-bold text-gray-400 px-2 sm:px-4">
          VS
        </div>
        <PlayerScore
          name={match.playerB}
          score={currentGame.scoreB}
          gamesWon={gamesWonB}
          isServing={match.server === Side.B}
          servingCourt={servingCourt}
          side={Side.B}
        />
      </div>
      <div className="text-center mt-4 text-gray-400">
        Game {currentGame.gameIndex} | Best of {match.bestOf}
      </div>
    </div>
  );
};

export default Scoreboard;

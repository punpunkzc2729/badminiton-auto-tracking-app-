import { Side, ServingCourt, Game, Match } from '../types';

export const getServingCourt = (score: number): ServingCourt => {
  return score % 2 === 0 ? ServingCourt.RIGHT : ServingCourt.LEFT;
};

const TARGET_SCORE = 21;
const MAX_SCORE = 30;

export const isGameOver = (scoreA: number, scoreB: number): boolean => {
  if (scoreA >= MAX_SCORE || scoreB >= MAX_SCORE) {
    return (scoreA === MAX_SCORE && scoreB === MAX_SCORE - 1) || (scoreB === MAX_SCORE && scoreA === MAX_SCORE - 1);
  }

  if (scoreA >= TARGET_SCORE || scoreB >= TARGET_SCORE) {
    return Math.abs(scoreA - scoreB) >= 2;
  }

  return false;
};

export const getGameWinner = (scoreA: number, scoreB: number): Side | null => {
    if (!isGameOver(scoreA, scoreB)) return null;
    return scoreA > scoreB ? Side.A : Side.B;
}

export const isMatchOver = (games: Game[], bestOf: 3 | 5): boolean => {
    const winsA = games.filter(g => g.winner === Side.A).length;
    const winsB = games.filter(g => g.winner === Side.B).length;
    const targetWins = Math.ceil(bestOf / 2);

    return winsA === targetWins || winsB === targetWins;
}

export const getMatchWinner = (games: Game[], bestOf: 3 | 5): Side | null => {
    if (!isMatchOver(games, bestOf)) return null;
    const winsA = games.filter(g => g.winner === Side.A).length;
    const winsB = games.filter(g => g.winner === Side.B).length;
    return winsA > winsB ? Side.A : Side.B;
}
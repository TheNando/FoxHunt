import { atom } from 'jotai';
import { GraphData } from 'js-client-library';

export const isDialogOpenAtom = atom(false);

export const isShiftDownAtom = atom(0);

const roomChars = 'abcdefghijklmnopqrstuvwxyz';
const charsLength = roomChars.length;

export const genRoomCode = () =>
    [...'XXXX']
        .map(() => roomChars.charAt(Math.floor(Math.random() * charsLength)))
        .join('')
        .toUpperCase();

export const getEdgePayload = (data: GraphData, source: string, target: string, edgeKind: string) => {
    return {
        source_object_id: data.nodes[source].objectId,
        target_object_id: data.nodes[target].objectId,
        edge_kind: edgeKind,
        properties: {},
    };
};

import { apiClient } from 'bh-shared-ui';
import { atom } from 'jotai';
import { GraphData } from 'js-client-library';
import { useQuery } from 'react-query';

const roomChars = 'abcdefghijklmnopqrstuvwxyz';
const charsLength = roomChars.length;

export const isDialogOpenAtom = atom(false);

export const isShiftDownAtom = atom(0);

export const roomCodeAtom = atom('WUEF'); // TODO: Remove hardcoded room code

export const createGameStateNode = (roomId: string, role: string) => {
    return {
        object_id: crypto.randomUUID(),
        labels: ['Foxhunt', roomId],
        properties: {
            type: 'state',
            [role]: 'ready',
        },
    } as any; // Query expects Node type, but Create is custom so any is used
};

export const getEdgePayload = (data: GraphData, source: string, target: string, edgeKind: string) => {
    return {
        source_object_id: data.nodes[source].objectId,
        target_object_id: data.nodes[target].objectId,
        edge_kind: edgeKind,
        properties: {},
    };
};

export const genRoomCode = () =>
    [...'XXXX']
        .map(() => roomChars.charAt(Math.floor(Math.random() * charsLength)))
        .join('')
        .toUpperCase();

// `MATCH (n:Foxhunt) OPTIONAL MATCH (n)-[r]-(m:Foxhunt) RETURN n, r, m;`

const makeFoxHuntCypher = (roomId: string) =>
    `MATCH (n:${roomId}) OPTIONAL MATCH (n)-[r]-(m:${roomId}) RETURN n, r, m;`;

export const useFoxHuntCypherQuery = (roomId: string) =>
    useQuery<any>({
        queryKey: ['foxhunt', roomId],
        queryFn: () => apiClient.cypherSearch(makeFoxHuntCypher(roomId)),
        enabled: !!roomId,
        // refetchInterval: 1000,
    });

/*
{
    "object_id":"2a29c884-29ed-407f-a826-62e83700a1b8",
    "labels":["Foxhunt","MWVH"],
    "properties":{"type":"state","fox":"ready"}
}
*/

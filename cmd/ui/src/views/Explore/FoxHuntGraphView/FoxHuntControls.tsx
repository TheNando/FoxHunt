import { Button, ButtonGroup, TextField, ToggleButton, ToggleButtonGroup, Tooltip } from '@mui/material';
import { useCreateNodeMutation } from 'bh-shared-ui';
import { useAtom } from 'jotai';
import { useState } from 'react';
import { createGameStateNode, genRoomCode, roomCodeAtom } from './foxhunt';

const TOOLTIP_SLOT_PROPS = { tooltip: { sx: { fontSize: '1.5rem' } } };

const SEPARATOR = <div className='w-0 block border-l-2 border-neutral-400' />;

export const FoxHuntControls = () => {
    const [role, setRole] = useState<'fox' | 'specter' | 'hound' | ''>('');
    const [roomCode, setRoomCode] = useAtom(roomCodeAtom);

    const { mutate: startGame } = useCreateNodeMutation();

    const hasValidRoomId = roomCode.length === 4;
    const isReadyToStart = hasValidRoomId && role !== '';

    let openStep = role === '' ? 'role' : '';
    if (!openStep && roomCode === '') openStep = 'room';
    if (!openStep && roomCode !== '') openStep = 'start';

    // TODO: Disable tooltip and start button if query contains state node

    const updateRoomCode = (event: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) =>
        setRoomCode(event.target.value.toUpperCase());

    const triggerGameStart = () => startGame(createGameStateNode(roomCode, role));

    return (
        <div className='flex gap-4'>
            <Tooltip slotProps={TOOLTIP_SLOT_PROPS} title='1) Select a Role' open={openStep === 'role'} arrow>
                <ToggleButtonGroup
                    aria-label='Join as'
                    color='primary'
                    exclusive
                    onChange={(_, newRole) => setRole(newRole)}
                    value={role}>
                    <ToggleButton value='fox'>Fox</ToggleButton>
                    <ToggleButton value='specter'>Specter</ToggleButton>
                    <ToggleButton value='hound'>Hound</ToggleButton>
                </ToggleButtonGroup>
            </Tooltip>

            {SEPARATOR}

            <Tooltip
                slotProps={TOOLTIP_SLOT_PROPS}
                title='2) Create a room or enter room id and click Join'
                open={openStep === 'room'}
                arrow>
                <ButtonGroup>
                    <Button variant='outlined' onClick={() => setRoomCode(genRoomCode())}>
                        Create Room
                    </Button>
                    <Button disabled={!hasValidRoomId} variant='outlined' onClick={triggerGameStart}>
                        Join Room
                    </Button>
                </ButtonGroup>
            </Tooltip>

            <TextField
                label='Room ID'
                onChange={updateRoomCode}
                sx={{ width: 90 }}
                value={roomCode}
                variant='standard'
                inputProps={{ maxLength: 4 }}
            />

            {SEPARATOR}

            <Tooltip
                slotProps={TOOLTIP_SLOT_PROPS}
                title='3) Start Game. Share code with other player and specters.'
                open={openStep === 'start'}
                arrow>
                <Button disabled={!isReadyToStart} variant='outlined' onClick={triggerGameStart}>
                    Start Game
                </Button>
            </Tooltip>
        </div>
    );
};

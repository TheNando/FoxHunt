import { Button, ButtonGroup, TextField } from '@mui/material';
import { useState } from 'react';
import { genRoomCode } from './foxhunt';

export const FoxHuntControls = () => {
    const [roomCode, setRoomCode] = useState<string>(genRoomCode());

    const updateRoomCode = (event: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
        setRoomCode(event.target.value);
    };

    return (
        <div className='flex gap-4'>
            <TextField label='Room Code' value={roomCode} onChange={updateRoomCode} />

            <ButtonGroup variant='outlined' aria-label='Small button group'>
                <Button>Fox</Button>
                <Button variant='contained'>Specter</Button>
                <Button>Hound</Button>
            </ButtonGroup>
        </div>
    );
};

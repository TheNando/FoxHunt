import {
    Button,
    Dialog,
    DialogActions,
    DialogContent,
    DialogDescription,
    DialogPortal,
    DialogTitle,
} from '@bloodhoundenterprise/doodleui';
import { useCreateNodeMutation } from 'bh-shared-ui';
import { useAtom } from 'jotai';
import { useEffect, useState } from 'react';
import { isDialogOpenAtom } from './foxhunt';

const makePayload = () =>
    JSON.stringify(
        {
            object_id: crypto.randomUUID(),
            labels: ['Foxhunt'],
            properties: {
                name: '',
            },
        },
        null,
        4
    );

export const AddNodeDialog = () => {
    const [node, setNode] = useState(makePayload());
    const [isDialogOpen, setIsDialogOpen] = useAtom(isDialogOpenAtom);
    const { mutateAsync: addNode } = useCreateNodeMutation();

    const updateTextarea = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
        setNode(e.target.value);
    };

    const doAddNode = () => {
        addNode(JSON.parse(node));
        setIsDialogOpen(false);
    };

    const cancel = () => {
        setIsDialogOpen(false);
    };

    useEffect(() => {
        setNode(makePayload());
    }, [isDialogOpen]);

    return (
        <Dialog open={isDialogOpen}>
            <DialogPortal>
                <DialogContent>
                    <DialogTitle>Add Node</DialogTitle>
                    <DialogDescription>
                        <textarea className='w-full h-48' onInput={updateTextarea} value={node}></textarea>
                    </DialogDescription>
                    <DialogActions>
                        <Button variant='tertiary' onClick={cancel}>
                            Cancel
                        </Button>
                        <Button variant='primary' onClick={doAddNode}>
                            Ok
                        </Button>
                    </DialogActions>
                </DialogContent>
            </DialogPortal>
        </Dialog>
    );
};

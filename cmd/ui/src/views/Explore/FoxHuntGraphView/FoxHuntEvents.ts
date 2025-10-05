import React, { useEffect } from 'react';

import { useRegisterEvents, useSigma } from '@react-sigma/core';
import '@react-sigma/core/lib/react-sigma.min.css';
import Sigma from 'sigma';

const disableCameraControls = (sigma: Sigma) => {
    const mouseCaptor = sigma.getMouseCaptor();
    if (mouseCaptor) {
        mouseCaptor.enabled = false;
    }
};

const cleanupCameraControls = (sigma: Sigma) => {
    const mouseCaptor = sigma.getMouseCaptor();
    if (mouseCaptor) {
        mouseCaptor.enabled = true;
    }
};

export const FoxHuntEvents: React.FC = () => {
    const registerEvents = useRegisterEvents();
    const sigma = useSigma();

    useEffect(() => {
        disableCameraControls(sigma);

        registerEvents({
            downNode: (e) => {
                sigma.getGraph().setNodeAttribute(e.node, 'highlighted', true);
            },
            mouseup: () => {},
            mousedown: () => {
                if (!sigma.getCustomBBox()) sigma.setCustomBBox(sigma.getBBox());
            },
            mousemove: () => {},
        });

        // Cleanup function to re-enable captors when component unmounts
        return () => {
            cleanupCameraControls(sigma);
        };
    }, [registerEvents, sigma]);

    return null;
};

// Copyright 2025 Specter Ops, Inc.
//
// Licensed under the Apache License, Version 2.0
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// SPDX-License-Identifier: Apache-2.0

import { SigmaContainer } from '@react-sigma/core';
import '@react-sigma/core/lib/react-sigma.min.css';
import getNodeProgramImage from 'sigma/rendering/webgl/programs/node.image';
import { FoxHuntControls } from './FoxHuntControls';
import { FoxHuntEvents } from './FoxHuntEvents';
import { useFoxHuntGraph } from './useFoxHuntGraph';

const GRAPH_STYLE: React.CSSProperties = {
    border: '1px solid black',
    flexGrow: 1,
};

const FoxHuntPage = () => {
    const { setSigma } = useFoxHuntGraph();

    return (
        <div className='flex flex-col h-full p-8 gap-4'>
            <FoxHuntControls />

            <div style={GRAPH_STYLE}>
                <SigmaContainer
                    ref={setSigma}
                    settings={{
                        nodeProgramClasses: {
                            image: getNodeProgramImage(),
                        },
                    }}>
                    <FoxHuntEvents />
                </SigmaContainer>
            </div>
        </div>
    );
};

export default FoxHuntPage;

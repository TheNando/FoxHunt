import { useEffect, useState } from 'react';

import { useAtomValue } from 'jotai';
import Sigma from 'sigma';
import { roomCodeAtom, useFoxHuntCypherQuery } from './foxhunt';

const GRID_COLS = 15;
const GRID_ROWS = 9;
const GRID_POINT_SIZE = 12;
const GRID_NODE_SIZE = 35;

const RED_NODE = '#ff4444';
const BLUE_NODE = '#3333ff';

const HOUND_IMAGE =
    'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAEAAAABACAYAAACqaXHeAAAO6ElEQVR4AexZC3RV1Zn+9nneV3JvcpNAEhIgQHhEHkEJSnBgithxxoWvajvjsmqZkTpLcQ0zdSl1OtjR6nTZglbXmhl1nLaryyLFUqxapS1RqpZ35SESwktC3gl53Ufu45x++1xQEknMk7qWuev/zz773/9j//9+/WdfBV/w32gAvuATAKMzYHQGfMEjMLoEvuATYHQTHF0Cf6ElkEm73xMCjapAkmUd698m+okXFS7mDPDQsxLiS15DNOb7tQdvvdSf9exXc5Svz/OPYf0R0lvYvp44g+gmjjhcrABcRU/W5Pm1/X9f6r150505yo6V2fj+NR78zRQVj33ZA1mXdLbfQr4D5H+IuIQ4ojDSAZCj/qQixE//bbH/W0/fkCF+cG06SnIUiLNuGZff7rzJuqQ/wfYfXZ8hVi3yr1YU8RM2riOO2GxQqHykYBwVb8r16/e+vjw49p4FHlxeoJF0HqgG3PNuA1ieowq+XFGo4d5yD177RjBvTJq+kqRNxFzisIMy7BpTCvMA8czlEzxLt/xTUMzM1WGo+PSPu5/QdYAlevxM8s+i3O/uyhTzxruvZvOTxGzikKCn8EgEwKSR28rGm8t+eG0aMt1yTAHLBv5YbeE/34rhcLNFlk/Dh00WHmH7nlobNvklR6ZHwVoui9JxrptZ53SBwXLYYCQCUJDl1R69a74XEzIUJOlIgv7+6rCF4qCCf19k4MQZGw0hNtANgVQp69VtwENsH+8XeK0qCSkn5YsyFdxT7kWWT/s+RQqJwwYjEYClpfm6+uViAxYEmiMC++qBSzNs/P+eGJIWsHC8igy3AiWQT0eEU8qZUj5eodMCP94bw8x0YGeNjeawcPRcPcXAnFxNBbCUOGww7AHQFHFvVpqO6vbUNN5bHXPm/wvvdmFhpuo449EAoajwLFkFm3Pdvfhep+6ie3LEyzM1/PSPXRC2wK7TcfIA1W02xvoNUP89GMbfcAfgb9NconhRkYlGTvEjXOuTgyoaIxY2n4xg3R/aUfmnGE5WJWCW3QE9T+ZFgD5uDvQ5X8OJIwmn/YfbWvHyiTA64qllU9mURFPYxpWTXEgzxVT6LzdFFkMHZegqPtawSgAvzcoy1Rwv0BJKorZTYMPBOO7Z2ITr/uFOMAbobLfQGfVCHb8AHHaAywRQoBYtRkfIRLjDQnVUYPHf3Yh/3tCIVw7HURdiztyZQJbLxmVjTJV5xUYA9xOHDMMVgFXsyRP/WpLunZyuoi2SRH1HAmX5CrYdCmNuQMcrP3sB11wyAUfDSajuNPquUuQsCJbMBTSvH4c7k1g0JR8Vm1/GLL+OioNhXDFOQQPp7dEkitI13F+S5qPE40Rpl8XgYTgCEKT5B9gpUR7UkEZnWUdnXCDMZfBQiRfX3PUvuP3rt+NQ1MChtqRsBiMA5yedd1AgmbBxqD2JkyIN31i+HDeufAAPTvcixOkfoT7JZqZpmM894tsz02X1AeqQ9lkMDpTBiXWT+mbQpfnLgzonMvBXk01nh/e7FJgeG1On6yjd8xyuPPFLrB5bg2UTTRj+DKim6+wBSF02nLoRyMRXuM4fHFON8qpfoOS9ZzC9RANZ4eepIXFxsenYKcvQkGGqfkrfRRw0DEcAvlSeLdM5OA4VBARk8iKPuY3vdyEjKDCzVMesuTpKiEWTTIxdch2MjGwI2W06L0tXZjbyr1qGCUUGLiH/bPLOYulnLrFpfxcCDGiQSdF46qeIlMTCHINp5NCOxaEGQMr7y7MM6QNktqeTks7OaqqA0mrjrWMJKKQJciQSQDJzBrJK5wOSAKQKtkFVEJw7H1bmNC6FFF3KvX08CZuJk6YpcPQqwrED/ham7KbzVWpgMXBg1wYudJ6ENJ4c40qpsdiNaFLA1AQSPMOnZ6l4+I32j9mTSQW2fyLMzByHxhTAmTXOiPLhzh6LZNpEJMjnMPCx5vU2TOdRCtvi94RALMH8gnbYhLN2k3yXS4HFwEEZuEg3iYmKIryQnpDMQUczjz8OFmzLgukV4L7IlhTowVwU3iDT+VQd0hE67kTBIQkUXH8r9OBYpyYfQV3A8DGgzCB1Hhz1nRY4CWQTQLuKED5WJhMHBcqgpD4RmpGhKznquelsA+/XJiCXQYRJjOER6HK8dPqKUDITnuzcT6TJ78z3TyjwjRmHcCIgfXOoUT41l0AoZjl6369LMEMkkSDtBgwli6/FxEHBUAMwfkq6FpCfruesv13Z5XS0hsedYgBuN4eNjUJVkb1sJR2zWCNw9KzOJoR+8yisUDMjlKLLmASvXQnJTy6YhgLVBGqpTwb2naouSXZQ2p0e0DJYmUgcFAw1AL6yoK4bipzLcMb6Eo5WR8xGu0yGwhZK8hgFyJ+AK28KGpqaEak/gba9b6DtV/+BrsoKtL/yXbT/6U1EGz5CI9vdBdMokNJ5Sb6JBuppiyaZW9iYxv021QJIu5dl6DqZvcQLwmcRhxIA6Zl3HM/ncx2SxuYwUXlpXxcuKzTx7PYI8v2aJEPobpYCnaer8eFz63DwR4/i2LZ9OP5hHMcqduPgU9/DoefXoqP2NANJjQ4/MCVbw/9Sz7wCExuot5SZIBU5QC7k0z4rMgCyP3wdGAwlAEEhMIEzuZtFqTDCbG7heB317TEcbYql2j0BgDu5dqYB1ft34bljXfjx8RiaTIVlHM8djaBm73boLfKG3IKQ/JSsaoo7esqpL8xloMo1Qvo5kPYZiAmsDyojlP2l7KCgME1XSnpKejSBIl1DVUvSObffPZ5as8KXw4+dMF6s2In7tjVj/f5W/N+uM7jlxXo8z/LnB9pw37tn8Ittexw+xZvy5/dHIpBZ5ZHmJCZQr9R/vk0ZD6+uyE1QXi6c39Svd6VfXBdmCoxxqbk03q2Vo4GaMwkcro1jwUQ3qltjTrvKy49YVwz7T9ajjvuD7LhMnOK8AJClrNfwQ+lQbSvi8SSU9NRpcao1jvIiNyrr4qijXqnfUXj24eOZO9alFrCaihhfBgJDCQAKPYo7Q+/ZJWBqmop8HtrLZrh4ZtvgCQZj8pXwp3mwYO40GKrA3KAhLzecvsrNbEZAd+jzZxbB73NDL16MWBJQhQ2pJ99QHb2OwHmPDG6KhV7Fcx5pQK9DCYCWbSrCQ2d6WnSTtuNYDG4uWJUprrzW0gtmQzNcWFo2FavLAshzq7wek+MOxDkFJvo0rLkiA0vnTYGqMRiFpWiKABrlTcXGjqMxuKi3py1pP4f9IF2eBiwGBsrA2D/m1hQFZSY7pIiPad1eptFBjenwjLEu1Kp5sFUDzc2tmJDjwdzpHigqOOIp8wb1GBowq9iNvEwX6htbYCsGakUuZuWZkHqmU183A2cr0r70n5rKSNKIAwLKDYj/HLPPpYgbAnrv4vI7pZ63Pz5TIDbjJggh4PNxpnK0S/M03DnZjbXlAVw7juWCDNzO+uxxGg8KC+m87xCCciU3w2cqPAUsBDnVzxnvWQYMBS5N3Ei6TItZ9B9696BvHb4clzpDTtu+2OSUPdoYw+SZc5i+KlBVFXY8hK5IArNKTVw918DUAJfFpQZmzzERJx1s1zSVagUmlcxEZWMcphxmUnqDIi4f9mca2y9aADwZhlDz3L3HT67ugCnQEbXgcvlw8lQ1Pjh8DBbvxT38uHG7md6eTqK5K4nGmiRM1l38dkjyVDjwQRWqjp2Ax+dHG0+GALNLqY8OXhBy2Q/ZHzZ6iQOC3j3oXY1c9eVyjMw+pOkHNK5I+edGQQG/Agu5nkuKoRomP5V1bN8Zw02/bsGLxzpwwytnsJN1CwbbXSidPQ1TJhViXP5YJLhkdOph0WuPZD9kf8iwkCj7x6J/0IcLvSqwuTzvznKzV72yAPwcQA0/XYVukMuCgIL4yV2o/eWT2FTRiq21MayYnoaVM9Nwd0ka3qyJYTPpdZvWkW83QAlefYBHB+p5J9jV1xQAkM1Nkv1awdfP4CTHeaCc997fV7lpz10yRjrWu0iMDmw9ngBzGny0bzuiu9ajffMaVLxzGnsZmH/8ay9ume/CHfwX+MZ5bqz4kg/vMdWV7W2bH0Zk9wYc27PNkX/rRBwJete7NWDJGJM5A+aSxyD2GwYTgEWmItRJ3rOTrhdTuqmggvl9KBSuvnXFavz300/j93ub8fT+MF49EsLyjS1YuaUV921hCvxmC+vNeKMqhKf2hVCxpwHPkv+2u7+DcDhy4rdHopwIfc9s2R+T/WJ3riL2GwYTgPsnp+sy2n0a8XNTa+M/QpyP39l16NTq777WgLtfbcZBpsYNHYn6nadi5VuronN+WxlZuPVodA7rCxo6E/UftCWw4tUzWPNqPfZU1qym/MNnmDp7uNH1ZVAeFMXsF3lWE/sNAw4AZ+IVV+aYn2nA1MCLEUvybeXjMd4QucNx+5t06FuszyO+S3yf+A5Rlu+xvNy27QfIt4r88kh7jLQKXVjwaJRkpS9YkusCA1HWF0/PNqUnoR914+wnfp+s1SGL/+05t33nbkWjFPgf4hPEU8QLwQkS/4u4lhgiSmjviME6xb/MZKUv9HBVfnaYumsYcAD4/b1tU3UX5AdOd1Xdazv5r259KFlJqnScxaAh2hBOVu7mqdGXBtmfTae6wP7t6IuvZ9uAA0AFdxxui+3/dU0UUXnYk9ATJPko1zovMp9hW4Q4FIhIPVX8LJZ6L6QowobNp6P4oLVLLqWvXYinN9pgAnCKV/PL15+M7Hr+eARnYp+edJX8Y3RHU6yORl8nfpqBxAGAlP/NzuZY7WHq7Skn7b/Afqz/KLJd9ovt1cR+w2ACIJXv5Oh/ZUttdON9u1uxtjKMHbys2EX8Ad8fOdAZb4lZci1XSeZhwKqWLuvxRw50xNZWRiDtbKetJ2hL2t9SF90QS9q30M5u4oBgsAGQRk5yvd3cFrdveqsuevSxA+2JRw+0W2/XRY90JqzryLCOOJzwVChhX19RFzki7TxOW9vqolXSPv+D+SoNfUQcMAwlANKYnJ4v8zHZsqETuQ+jmA2vE0cCpN5iaUciDUwhvkxkF/gcBAw1AIMw+fkSGQ3A52s8Ln5vRmfAxY/558vi6Az4fI3Hxe/N6Ay4+DEfXotD1fZnAAAA//9mArEoAAAABklEQVQDALqr7L1WmwTAAAAAAElFTkSuQmCC';

const FOX_IMAGE =
    'data:image/png;base64,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';

export const useFoxHuntGraph = () => {
    const roomId = useAtomValue(roomCodeAtom);
    const [sigma, setSigma] = useState<Sigma | null>(null);

    const { data } = useFoxHuntCypherQuery(roomId);
    console.log({ data });

    useEffect(() => {
        if (sigma) {
            const graph = sigma.getGraph();

            // Setup graph grid
            for (let col = 0; col < GRID_COLS; col++) {
                for (let row = 0; row < GRID_ROWS; row++) {
                    const node: any = { x: col, y: row, size: GRID_POINT_SIZE };

                    // TODO: Remove this once there are real player nodes
                    // Generate test nodes
                    if (Math.random() > 0.98) {
                        const isHound = Math.random() > 0.5;
                        node.type = 'image';
                        node.image = isHound ? HOUND_IMAGE : FOX_IMAGE;
                        node.color = isHound ? BLUE_NODE : RED_NODE;
                        node.size = GRID_NODE_SIZE;
                    }

                    graph.addNode(`${col}-${row}`, node);
                }
            }

            // Zoom out just a bit to add some padding
            // Use a small timeout to ensure the graph is fully rendered
            setTimeout(() => {
                const camera = sigma.getCamera();
                camera.setState({ ratio: 1.1 });
            }, 100);
        }
    }, [sigma]);

    return { setSigma };
};
